require 'spec_helper'

describe RoutingI18n do
  context do
    context do
      draw { scope(i18n: :ca) { scope(i18n: :en) {} } }

      it "prevents nesting I18n scopes" do
        expect { routes }.to raise_error("Nesting i18n scopes is not allowed!")
      end
    end

    it "properly merges i18n scopes" do
      route_set do
        scope(i18n: :es) do
          scope(path: :admin) do
            @scope[:i18n].should == :es
          end
        end
      end
    end
  end

  context do
    draw { scope(path: :ca, i18n: :ca) { resources(:users, only: :new) } }
    it "accepts other scope options" do
      path(:new_user_ca).should == "/ca/users/new"
    end
  end

  context do
    draw do
      scope(i18n: :ca) do
        resources :organizations
      end
      resources :users
    end

    locale :ca, <<-YAML
    routes:
      resources:
        organizations:
          path: organitzacions
        users:
          path: usuaris
    YAML

    it "does not suffix untranslated routes" do
      expect { path(:users_en) }.to raise_exception(NoMethodError)
    end
  end

  context do
    draw do
      scope(i18n: :ca) do
        get :about_us, to: "PageController#about", as: :about_us
        resource :organization
        resources :users, only: :new do
          post :ban, on: :member
          resources :organizations, only: :index
        end
      end
    end

    context do
      locale :ca, <<-YAML
        routes:
          path_names:
            new: nou
            about_us: sobre-nosaltres
      YAML

      it "translates globally defined path names" do
        path(:new_user_ca).should == "/users/nou"
      end

      it "translates global user-defined path names" do
        path(:about_us_ca).should == "/sobre-nosaltres"
      end
    end

    context do
      locale :ca, <<-YAML
        routes:
          resource:
            organization:
              path: organitzacio

          resources:
            organizations:
              path: organitzacions
            users:
              path: usuaris
              path_names:
                new: nou-usuari
                ban: bloquejar
      YAML

      it "translates resource path names" do
        path(:new_user_ca).should == "/usuaris/nou-usuari"
      end

      it "translates user-defined resource path names" do
        path(:ban_user_ca, 1).should == "/usuaris/1/bloquejar"
      end

      it "translates nested resources" do
        path(:user_organizations_ca, 1).should == "/usuaris/1/organitzacions"
      end

      it "translates singleton resources" do
        path(:organization_ca).should == "/organitzacio"
      end

      it "fallbacks to current locale when calling an non-i18n url helper" do
        I18n.with_locale(:ca) { path(:user_organizations, 1).should == "/usuaris/1/organitzacions" }
      end
    end
  end
end