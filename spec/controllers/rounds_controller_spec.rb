require 'spec_helper'

describe RoundsController, type: :controller do

  describe 'GET #index' do

    before(:each) { get :index }

    it 'renders a list of rounds' do

      expect(response).to render_template('index')
    end

    it 'assigns rounds to @rounds' do
      expect(assigns(:rounds)).to eq(Round.order('id desc'))
    end
  end

  describe 'GET #current' do
    before(:each) do
      login_as user if user
    end

    # We assume at least one round, always
    let!(:round) { create :round }

    context 'when the user is not logged in' do
      let(:user) { nil }
      it 'redirects to login prompt' do
        get :current
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when the current user has a last round' do
      let(:user) { create :player }
      it 'shows the users last-selected round' do
        expect(user).to receive(:last_round)
        expect(Round).to receive(:find_or_build_current_round).and_call_original
        get :current
        expect(response).to be_successful
        expect(response).to render_template('show')
        expect(assigns(:round)).to eq(Round.first)
      end
    end

    context 'when the current user does not have a last round' do
      let(:user) do
        create(:player).tap do |p|
          p.last_round = create(:round)
          p.save!
        end
      end

      it 'shows the users last round' do
        expect(user).to receive(:last_round)
        expect(Round).not_to receive(:find_or_build_current_round)
        get :current
        expect(response).to be_successful
        expect(response).to render_template('show')
        expect(assigns(:round)).to eq(Round.first)
      end
    end
  end

  describe 'GET #show' do
  end

end
