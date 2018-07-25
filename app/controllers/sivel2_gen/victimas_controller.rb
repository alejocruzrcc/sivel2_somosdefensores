# encoding: UTF-8
require 'date'
module Sivel2Gen
  class VictimasController < ApplicationController
    load_and_authorize_resource class: Sivel2Gen::Victima

    # Crea un nuevo registro para el caso que recibe por parametro 
    # params[:caso_id].  Pone valores simples en los campos requeridos
    def nuevo
      if params[:caso_id]
        @persona = Sip::Persona.new
        @victima = Victima.new
        @persona.nombres = 'N'
        @persona.apellidos = 'N'
        @persona.sexo = 'S'
        if !@persona.save
          respond_to do |format|
            format.html { render inline: 'No pudo crear persona' }
          end
          return
        end
        @victima.id_caso = params[:caso_id]
        @victima.id_persona = @persona.id
        @actorsocial_persona = Sip::ActorsocialPersona.new
        @actorsocial_persona.persona_id = @persona.id
        @actorsocial_persona.actorsocial_id = nil
        @actorsocial_persona.perfilactorsocial_id = nil
        @actorsocial_persona.save!
        if @victima.save
          respond_to do |format|
            format.js { render json: {
              'victima' => @victima.id.to_s,
              'persona' => @persona.id.to_s,
              'actorsocial_persona' => @actorsocial_persona.id.to_s
            } }
            format.json { render json: {
              'victima' => @victima.id.to_s, 
              'persona' => @persona.id.to_s,
              'actorsocial_persona' => @actorsocial_persona.id.to_s
            }, status: :created }
            format.html { render json: {
              'victima' => @victima.id.to_s, 
              'persona' => @persona.id.to_s,
              'actorsocial_persona' => @actorsocial_persona.id.to_s
            } }
          end
        else
          respond_to do |format|
            format.html { render action: "error" }
            format.json { render json: @victima.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render inline: 'Falta identificacion del caso' }
        end
      end
    end
  end
end
