require 'spec_helper'

describe RelationshipsController do
  let!(:settings) { Fabricate(:setting  ) }
  let(:jen      ) { Fabricate(:user     ) }
  let(:joe      ) { Fabricate(:user     ) }
  let(:jim      ) { Fabricate(:user     ) }
  before          { spec_signin_user(jen) }


  describe "GET search" do
    let!(:friends) { Fabricate(:relationship, user: jen, friend: joe) }

    context "with a matching user email" do
      before { get :search, user_id: jen.slug, search_string: jim.email }

      it "loads the search results" do
        expect(assigns(:search_results)).to eq( [jim] )
      end
      it "sets the searched instance variable to true" do
        expect(assigns(:searched)).to eq( true )
      end
      it "renders the search page" do
        expect(response).to render_template 'search'
      end
    end

    context "with a matching username" do
      before { get :search, user_id: jen.slug, search_string: jim.username }

      it "loads the search results" do
        expect(assigns(:search_results)).to eq( [jim] )
      end
      it "sets the searched instance variable to true" do
        expect(assigns(:searched)).to eq( true )
      end
      it "renders the search page" do
        expect(response).to render_template 'search'
      end
    end

    context "with no match" do
      before { get :search, user_id: jen.slug, search_string: "incorrect" }

      it "loads the search results" do
        expect(assigns(:search_results)).to eq( [] )
      end
      it "sets the searched instance variable to true" do
        expect(assigns(:searched)).to eq( true )
      end
      it "renders the search page" do
        expect(response).to render_template 'search'
      end
    end
  end

  describe "POST create" do

    context "between two Users" do
      before { post :create, { user_id: jen.slug, friend_slug: joe.slug } }

      it "creates a new relationship for the user" do
        expect(Relationship.count).to eq(1)
      end
      it "creates a 1-way relationship between the user and the friend" do
        expect(jen.friends).to     include(joe)
        expect(jen.friends).to_not include(jen)
      end
      it "flashes a success message to the user" do
        expect(flash[:success]).to include("following")
      end
      it "redirects the user to their home page" do
        expect(response).to redirect_to user_relationships_path(jen)
      end
    end

    context "for disallowed attempts" do
      context "for users attempting to befriend themselves" do
        before { post :create, { user_id: jen.slug, friend_slug: jen.slug } }

        it "does not create a new relationship" do
          expect(Relationship.count).to eq(0)
        end
        it "flashes an error message to the user" do
          expect(flash[:error]).to be_present
        end
        it "renders the friend search page" do
          expect(response).to render_template 'search'
        end
      end
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { post :create, { user_id: jen.slug, friend_slug: jen.slug } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { post :create, { user_id: jen.slug, friend_slug: jen.slug } }
      end
    end
  end



  describe "GET index" do
    let!(:friends) { Fabricate(:relationship, user: jen, friend: joe) }
    before         { get :index, user_id: jen.slug }

    it "loads the user's friends" do
      expect(assigns(:friends)).to eq( jen.friends )
    end
    it "renders the index page" do
      expect(response).to render_template 'index'
    end
  end



  describe "DELETE destroy" do
    context "for a befriended user" do
      let!(:friends) { Fabricate(:relationship, user: jen, friend: joe) }
      before         { delete :destroy, id: jen.slug, user_id: jen.slug, friend_slug: joe.slug }

      it "destroys the relationship between users" do
        expect(Relationship.count).to eq(0)
      end
      it "flashes a success message to the user" do
        expect(flash[:success]).to be_present
      end
      it "redirects the user to the user relationships page" do
        expect(response).to redirect_to user_relationships_path(jen)
      end
    end

    context "for a relationship between other users" do
      let!(:friends) { Fabricate(:relationship, user: jim, friend: joe) }
      before         { delete :destroy, id: jen.slug, user_id: jim.slug, friend_slug: joe.slug }

      it "does NOT the relationship between other users" do
        expect(Relationship.count).to eq(1)
      end
      it "flashes a success message to the user" do
        expect(flash[:error]).to be_present
      end
      it "redirects the user to the user relationships page" do
        expect(response).to redirect_to home_path
      end
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { delete :destroy, id: jen.slug, user_id: jen.slug, friend_slug: joe.slug }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { delete :destroy, id: jen.slug, user_id: jen.slug, friend_slug: joe.slug }
      end
    end
  end
end
