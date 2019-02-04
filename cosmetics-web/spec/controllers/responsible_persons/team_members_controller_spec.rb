require 'rails_helper'

RSpec.describe ResponsiblePersons::TeamMembersController, type: :controller do
  before do
    sign_in
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      responsible_person = ResponsiblePerson.create
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      responsible_person = ResponsiblePerson.create
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template('responsible_persons/team_members/index')
    end
  end
end
