require "rails_helper"

RSpec.describe UpdateCorrectiveAction, :with_stubbed_mailer, :with_stubbed_elasticsearch, :with_stubbed_antivirus, :with_test_queue_adapter do
  include ActionDispatch::TestProcess::FixtureFile

  subject(:result) do
    described_class.call(
      corrective_action: corrective_action,
      corrective_action_params: corrective_action_params,
      user: user
    )
  end

  let(:user)             { create(:user, :activated) }
  let(:case_creator)     { create(:user, :activated, team: user.team) }
  let(:investigation)    { create(:allegation, creator: case_creator) }
  let(:editor_team)      do
    create(:team).tap do |t|
      AddTeamToCase.call!(
        investigation: investigation,
        team: t,
        collaboration_class: Collaboration::Access::Edit,
        user: user
      )
    end
  end
  let(:case_editor)      { create(:user, :activated, team: editor_team) }
  let(:product)          { create(:product) }
  let(:business)         { create(:business) }
  let(:old_date_decided) { Time.zone.today }
  let(:related_file)     { true }
  let(:other_action)     { nil }
  let(:action)           { (CorrectiveAction.actions.values - %w[Other]).sample }
  let!(:corrective_action) do
    create(
      :corrective_action,
      :with_file,
      investigation: investigation,
      date_decided: old_date_decided,
      product: product,
      business: business,
      action: action,
      other_action: other_action
    )
  end

  let(:corrective_action_params) do
    {
      date_decided_day: corrective_action.date_decided.day,
      date_decided_month: corrective_action.date_decided.month,
      date_decided_year: corrective_action.date_decided.year,
      related_file: "Yes",
      other_action: new_other_action,
      action: new_action,
      file: {
        description: new_file_description
      }
    }
  end

  let(:new_date_decided) { (old_date_decided - 1.day).to_date }
  let(:new_file_description) { "new corrective action file description" }
  let(:new_document) { fixture_file_upload(file_fixture("files/corrective_action.txt")) }
  let(:new_action) { (CorrectiveAction.actions.values - %W[Other #{corrective_action.action}]).sample }
  let(:new_other_action) { corrective_action.other_action }

  describe "#call" do
    context "with no parameters" do
      it "returns a failure" do
        expect(described_class.call).to be_failure
      end
    end

    context "when missing parameters" do
      let(:params) do
        {
          corrective_action: corrective_action,
          user: user,
          file: { description: new_file_description }
        }
      end

      it { expect(described_class.call(params.except(:corrective_action))).to be_a_failure }
      it { expect(described_class.call(params.except(:user))).to be_a_failure }
    end

    context "with the required parameters" do
      context "when no changes have been made" do
        let(:new_action) { corrective_action.action }

        shared_examples "it does not create an audit log" do
          specify { expect { result }.not_to change(corrective_action.investigation.activities.where(type: "AuditActivity::CorrectiveAction::Update"), :count) }
        end

        it "does not change corrective action" do
          expect { result }.not_to change(corrective_action, :attributes)
        end

        context "with documents attached" do
          let(:new_file_description) { corrective_action.documents.first.metadata.fetch(:description) }

          it "does not change the attached document" do
            expect { result }.not_to change(corrective_action.documents, :first)
          end

          it "does not change the attached document's metadata" do
            expect { result }.not_to change(corrective_action.documents.first, :metadata)
          end

          include_examples "it does not create an audit log"
        end

        context "with no documents attached" do
          before { corrective_action.documents.detach }

          it "does not change the attached document's" do
            expect { result }.not_to change(corrective_action.documents, :empty?)
          end

          include_examples "it does not create an audit log"
        end
      end

      context "when changes have been made" do
        before do
          corrective_action_params[:date_decided_day] = new_date_decided.day
          corrective_action_params[:date_decided_month] = new_date_decided.month
          corrective_action_params[:date_decided_year] = new_date_decided.year
        end

        it "updates the corrective action" do
          expect {
            result
          }.to change(corrective_action, :date_decided).from(old_date_decided).to(new_date_decided)
        end

        it "generates an activity entry with the changes" do
          result

          activity_timeline_entry = investigation.activities.reload.order(:created_at).find_by!(type: "AuditActivity::CorrectiveAction::Update")
          expect(activity_timeline_entry).to have_attributes({})
        end

        def expected_email_subject
          "Corrective action edited for Allegation"
        end

        def expected_email_body(name)
          "#{name} edited a corrective action on the allegation."
        end

        it_behaves_like "a service which notifies the case owner"

        context "when removing the previously attached file" do
          before { corrective_action_params[:related_file] = "off" }

          it "removes the related file" do
            expect { result }
              .to change(corrective_action.reload.documents, :any?).from(true).to(false)
          end

          it "creates an audit log" do
            expect { result }
              .to change(investigation.activities.where(type: "AuditActivity::CorrectiveAction::Update"), :count).from(0).to(1)
          end
        end
      end
    end

    context "with no changes" do
      before { corrective_action.documents.detach }

      let(:corrective_action_params) do
        ActionController::Parameters.new(
          date_decided: {
            day: corrective_action.date_decided.day,
            month: corrective_action.date_decided.month,
            year: corrective_action.date_decided.year,
          },
          action: corrective_action.action,
          legislation: corrective_action.legislation,
          duration: corrective_action.duration,
          details: corrective_action.details,
          measure_type: corrective_action.measure_type,
          related_file: corrective_action.related_file,
          file: { description: "" }
        ).permit!
      end

      it "does not create an audit activity" do
        expect { result }.not_to change(corrective_action.investigation.activities, :count)
      end
    end

    context "with no previously attached file" do
      let(:corrective_action) do
        create(
          :corrective_action,
          investigation: investigation,
          date_decided: old_date_decided,
          product: product,
          business: business,
          action: action,
          other_action: other_action
        )
      end

      let(:corrective_action_params) do
        ActionController::Parameters.new(
          date_decided: {
            day: corrective_action.date_decided.day,
            month: corrective_action.date_decided.month,
            year: corrective_action.date_decided.year,
          },
          action: new_action,
          legislation: corrective_action.legislation,
          duration: corrective_action.duration,
          details: corrective_action.details,
          measure_type: corrective_action.measure_type,
          related_file: corrective_action.related_file,
          file: {
            file: fixture_file_upload(file_fixture("files/corrective_action.txt")),
            description: new_file_description
          }
        ).permit!
      end

      it "stored the new file with the description", :aggregate_failures do
        result

        document = corrective_action.reload.documents.first
        expect(document.filename.to_s).to eq("corrective_action.txt")
        expect(document.metadata[:description]).to eq(File.basename(new_file_description))
      end

      context "when not adding a new file" do
        before { corrective_action_params[:file].delete(:file) }

        it "stored the new file with the description", :aggregate_failures do
          expect { result }.not_to raise_error
        end
      end
    end

    context "with a new file" do
      before { corrective_action_params[:file][:file] = new_document }

      it "stored the new file with the description", :aggregate_failures do
        result

        document = corrective_action.reload.documents.first
        expect(document.filename.to_s).to eq("corrective_action.txt")
        expect(document.metadata[:description]).to eq(new_file_description)
      end
    end

    context "without a new file" do
      before do
        corrective_action_params[:file][:file] = nil
      end

      it "stored the new file with the description", :aggregate_failures do
        expect {
          result
        }.not_to change(corrective_action, :documents)
      end
    end

    context "when the action was previously Other" do
      let(:action)       { "other" }
      let(:other_action) { "Other action that should be cleared up once changed to a listed action" }
      let(:new_action)   { attributes_for(:corrective_action)[:action] }

      it "does clean the other_action field" do
        expect { result }.to change(corrective_action, :other_action)
                .from("Other action that should be cleared up once changed to a listed action").to(nil)
                .and change(corrective_action, :action).from("other").to(new_action)
      end
    end
  end
end
