require 'spec_helper'

describe ActionDispatch::Routing::I18n do
  locale :ca, <<-YAML
    routes:
      path_names:
        about_us: sobre-nosaltres
        edit: editar
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

  context do
    context do
      draw { scope(locale: :ca) { scope(locale: :en) {} } }

      it "prevents nesting I18n scopes" do
        expect { routes }.to raise_error("Nesting locale scopes is not allowed!")
      end
    end

    it "properly merges i18n scopes" do
      route_set do
        scope(locale: :es) do
          scope(path: :admin) do
            @scope[:locale].should == :es
          end
        end
      end
    end
  end

  context do
    draw { scope(path: :ca, locale: :ca) { resources(:organizations, only: :new) } }
    it "accepts other scope options" do
      path(:new_organization_ca).should == "/ca/organitzacions/new"
    end
  end

  context do
    draw do
      scope(locale: :ca) do
        resources :organizations
      end
      resources :users
    end

    it "does not suffix untranslated routes" do
      expect { path(:users_en) }.to raise_exception(NoMethodError)
    end
  end

  context do
    draw do
      scope(locale: :ca) do
        get :about_us, to: "pages_controller#about", as: :about_us
        resource :organization
        resources :users, only: :new do
          post :ban, on: :member
          resources :organizations, only: :index
        end
      end
    end

    context do
      it "translates globally defined path names" do
        path(:edit_organization_ca).should == "/organitzacio/editar"
      end

      it "translates global user-defined path names" do
        path(:about_us_ca).should == "/sobre-nosaltres"
      end
    end

    context do
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

      it "responds to non-i18n url helper method names if it has a fallback for the current locale" do
        I18n.with_locale(:ca) { routes.url_helpers.should respond_to(:user_organizations_path) }
      end

      it "does not respond to undefined methods" do
        I18n.with_locale(:ca) { routes.url_helpers.should_not respond_to(:unknown) }
      end

    end
  end
end
