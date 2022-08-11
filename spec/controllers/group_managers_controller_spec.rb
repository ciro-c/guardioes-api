require 'rails_helper'

RSpec.describe GroupManagersController, type: :controller do
    let(:valid_attributes) {
      skip("Add a hash of attributes valid for your model")
    }

    let(:invalid_attributes) {
      skip("Add a hash of attributes invalid for your model")
    }

    let(:valid_session) { {} }

    it "should check_authenticated_admin_or_manager and return nothing " do
        group_manager = GroupManager.create! valid_attributes
        current_admin = Admin.create! valid_attributes
        group_manager_controller = GroupManagersController.new
        assert_not group_manager_controller.check_authenticated_admin_or_manager
    end

    it "should check_authenticated_admin_or_manager and return nothing" do
        group_manager = GroupManager.create! valid_attributes
        group_manager_controller = GroupManagersController.new
        assert_not group_manager_controller.check_authenticated_admin_or_manager

    end

    it "should check_authenticated_admin_or_manager and return nothing" do
        current_admin = Admin.create! valid_attributes
        group_manager_controller = GroupManagersController.new
        assert_not group_manager_controller.check_authenticated_admin_or_manager
    end

    it "should check_authenticated_admin_or_manager and return json " do
        group_manager_controller = GroupManagersController.new
        expect(group_manager_controller.check_authenticated_admin_or_manager).to have_http_status(:ok)
        expect(group_manager_controller.check_authenticated_admin_or_manager.content_type).to eq('application/json')
    end

end
