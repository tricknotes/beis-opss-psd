require "rails_helper"

RSpec.describe RemoveProductFromCase, :with_stubbed_elasticsearch, :with_test_queue_adapter do
  let(:investigation) { create(:allegation, products: [product], creator: creator) }
  let(:product) { create(:product_washing_machine) }

  let(:user) { create(:user) }
  let(:creator) { user }
  let(:owner) { user }

  describe ".call" do
    context "with no parameters" do
      let(:result) { described_class.call }

      it "returns a failure" do
        expect(result).to be_failure
      end
    end

    context "with no investigation parameter" do
      let(:result) { described_class.call(product: product, user: user) }

      it "returns a failure" do
        expect(result).to be_failure
      end
    end

    context "with no product parameter" do
      let(:result) { described_class.call(investigation: investigation, user: user) }

      it "returns a failure" do
        expect(result).to be_failure
      end
    end

    context "with no user parameter" do
      let(:result) { described_class.call(investigation: investigation, product: product) }

      it "returns a failure" do
        expect(result).to be_failure
      end
    end

    context "with required parameters" do
      let(:result) { described_class.call(investigation: investigation, product: product, user: user) }

      it "returns success" do
        expect(result).to be_success
      end

      it "removes the product from the case" do
        result
        expect(investigation.reload.products).not_to include(product)
      end

      it "creates an audit activity", :aggregate_failures do
        result
        activity = investigation.reload.activities.first
        expect(activity).to be_a(AuditActivity::Product::Destroy)
        expect(activity.source.user).to eq(user)
        expect(activity.product).to eq(product)
        expect(activity.title(nil)).to eq("Removed: #{product.name}")
      end

      context "when the case owner is a user" do
        context "when the user is the same as the case owner" do
          it "does not send a notification email" do
            expect { result }.not_to have_enqueued_mail(NotifyMailer, :investigation_updated)
          end
        end

        context "when the user is another user than the case owner" do
          let(:owner) { create(:user, team: user.team) }

          before do
            ChangeCaseOwner.call!(investigation: investigation, user: user, owner: owner)
          end

          it "sends a notification email to the case owner" do
            expect { result }.to have_enqueued_mail(NotifyMailer, :investigation_updated).with(
              investigation.pretty_id,
              owner.name,
              owner.email,
              "Product was removed from the allegation by #{user.name}.",
              "Allegation updated"
            )
          end
        end
      end

      context "when the case owner is a team" do
        let(:owner) { create(:team, team_recipient_email: team_recipient_email) }
        let(:team_recipient_email) { nil }

        context "when the user is on the same team" do
          let(:user) { create(:user, team: owner) }

          it "does not send a notification email" do
            expect { result }.not_to have_enqueued_mail(NotifyMailer, :investigation_updated)
          end
        end

        context "when the user is on another team" do
          before do
            ChangeCaseOwner.call!(investigation: investigation, user: user, owner: owner)
          end

          context "when the team does not have an email" do
            let!(:active_user_owner_team) { create(:user, :activated, team: owner) }

            before do
              create(:user, team: owner)
            end

            it "sends an email to all active users on the team" do
              expect { result }.to have_enqueued_mail(NotifyMailer, :investigation_updated).with(
                investigation.pretty_id,
                active_user_owner_team.name,
                active_user_owner_team.email,
                "Product was removed from the allegation by #{user.name} (#{user.team.name}).",
                "Allegation updated"
              )
            end
          end

          context "when the team has an email" do
            let(:team_recipient_email) { Faker::Internet.email }

            it "sends a notification email to the team email" do
              expect { result }.to have_enqueued_mail(NotifyMailer, :investigation_updated).with(
                investigation.pretty_id,
                owner.name,
                owner.team_recipient_email,
                "Product was removed from the allegation by #{user.name} (#{user.team.name}).",
                "Allegation updated"
              )
            end
          end
        end
      end
    end
  end
end