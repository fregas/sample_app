require 'spec_helper'

describe "User pages" do
  # fix your indention as you go along.  Don't let it get crazy.  
  # each describe should have its "befores" and "its" indented one time below it.  This helps readibility.  

  # also, you have a lot of failing tests.  You want to create one test, get it passed and move to another.  
  # Don't write a bunch of code or a bunch of tests at once before getting them to pass.   Get the tiniest thing done 
  # and working before you move on to something else.  

  subject { page }

  describe "signup page" do
    
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      let(:password)  { 'blahblahblah' }
      let!(:old_user_count) { User.count} #instead of the change spect on line 75, I am checking the count here, then checking it against the new count later.  the let with the ! symbol makes sure this runs before any tests.  
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: password #we were missing let(:password) above causing errors.
        fill_in "Confirmation", with: password #you had the wrong name of the field.  
        click_button "Create my account"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') } 
      it { should have_link('Sign out', href: signout_path) } #this was failing because in your users_controller, you had not signed in the user
      it "increments the user count" do
        expect( User.count ).to eq(old_user_count + 1)
      end
      #specify { expect(user.reload.name).to  eq new_name } # I don't think these belong here.  These are checking an existing user and you are creating a new USER.  you might do something in a separate set of specs for updating existing user.  
      #specify { expect(user.reload.email).to eq new_email }
    end

    #so I played around w/ this spec.  I couldn't get it to work, because 
    #I think it needs all the setup above. "to change" just isn't a good thing to use
    # in this situation so I would remove this. I replaced it with the "increments user count" above
    it "should create a user" do 
      expect { click_button submit }.to change(User, :count).by(1)
    end

    describe "after saving the user" do #not sure what this set of specs is doing either.  it seems to be a dupe of the above specs
    # in describe "with valid information"
      before { click_button submit }
      let(:user) { User.find_by(email: 'user@example.com') }

      it { should have_link('Sign out', href: 'signout_path') }
      it { should have_title(user.name) }
      it { should have_selector('div.alert.alert-success', text: 'Welcome') }
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

    #Probably need to add specs to update a existing user here
  end
end
  
