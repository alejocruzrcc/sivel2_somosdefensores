Rails.application.routes.draw do

  scope 'somosdefensores/sivel2' do 
    devise_scope :usuario do
      get 'sign_out' => 'devise/sessions#destroy'

      # El siguiente para superar mala generación del action en el formulario
      # cuando se monta en sitio diferente a / y se autentica mal (genera 
      # /puntomontaje/puntomontaje/usuarios/sign_in )
      if (Rails.configuration.relative_url_root != '/') 
        ruta = File.join(Rails.configuration.relative_url_root, 
                         'usuarios/sign_in')
        post ruta, to: 'devise/sessions#create'
        get  ruta, to: 'devise/sessions#new'
      end
    end

    devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
      get 'usuarios/edit' => 'devise/registrations#edit', 
        :as => 'editar_registro_usuario'    
      put 'usuarios/:id' => 'devise/registrations#update', 
        :as => 'registro_usuario'            
    end
    resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 

    namespace :admin do
      ab = ::Ability.new
      ab.tablasbasicas.each do |t|
        if (t[0] == "") 
          c = t[1].pluralize
          resources c.to_sym, 
            path_names: { new: 'nueva', edit: 'edita' }
        end
      end
    end


    get '/casos/mapaosm' => 'sivel2_gen/casos#mapaosm'
  
    get '/graficar/victimizaciones_por_sexo' => 'fil23_gen/graficar#victimizaciones_por_sexo', 
      :as => 'graficar_victimizaciones_por_sexo'

    get '/graficarjs/plotly_victimizaciones_por_sexo' => 'graficarjs#plotly_victimizaciones_por_sexo', 
      :as => 'graficarjs_plotly_victimizaciones_por_sexo'

    get '/graficarjs/chartjs_victimizaciones_por_sexo' => 'graficarjs#chartjs_victimizaciones_por_sexo', 
      :as => 'graficarjs_chartjs_victimizaciones_por_sexo'


    root 'sivel2_gen/hogar#index'

  end

  mount Sip::Engine => "/somosdefensores/sivel2", as: 'sip'
  mount Mr519Gen::Engine => "/somosdefensores/sivel2", as: 'mr519_gen'
  mount Heb412Gen::Engine => "/somosdefensores/sivel2", as: 'heb412_gen'
  mount Sivel2Gen::Engine => "/somosdefensores/sivel2", as: 'sivel2_gen'

end
