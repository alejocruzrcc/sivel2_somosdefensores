# encoding: UTF-8
class Ability  < Sivel2Gen::Ability

  def organizacion_responable 
    'Somos Defensores'
  end

  def derechos 
    'Terminos'
  end

  BASICAS_PROPIAS = [
    ['', 'tipoamenaza']
  ]

  def tablasbasicas 
    Sip::Ability::BASICAS_PROPIAS + 
      Sivel2Gen::Ability::BASICAS_PROPIAS - [
        ['Sip', 'grupo'],
        ['Sip', 'oficina'],
        ['Sip', 'sectoractor'],
        ['Sip', 'trelacion'],
        ['Sivel2Gen', 'actividadoficio'],
        ['Sivel2Gen', 'escolaridad'],
        ['Sivel2Gen', 'estadocivil'],
        ['Sivel2Gen', 'iglesia'],
        ['Sivel2Gen', 'maternidad'],
        ['Sivel2Gen', 'resagresion']
      ] + 
      BASICAS_PROPIAS
  end

  def campos_plantillas
      n = Heb412Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.
        clone.merge(Sivel2Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone)
      c= n['Victima'][:campos] 
      if c.index(:profesion)
        c[c.index(:profesion)] = :perfilliderazgo
      end
      c+=
      [ :colectivohumano,
        :tamenaza1, 
        :tamenaza2, 
        :tamenaza3, 
        :tamenaza4, 
        :tamenaza5, 
        :tamenaza6, 
        :tamenaza7, 
        :tamenaza8, 
        :tamenaza9, 
        :tamenaza10, 
        :tamenaza11, 
        :tamenaza12, 
        :tamenaza13, 
        :tamenaza14, 
        :tamenaza15, 
        :tamenaza16, 
        :tamenaza17, 
        :tamenaza18, 
        :tamenaza19, 
        :tamenaza20, 
        :tamenaza21]

      n['Victima'][:campos] = c
      return n
    end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    # Sin autenticación puede consultarse información geográfica 
    can :read, [Sip::Pais, Sip::Departamento, Sip::Municipio, Sip::Clase]
    if !usuario || usuario.fechadeshabilitacion
      return
    end
    can :descarga_anexo, Sip::Anexo
    can :read, Sip::Actorsocial
    can :contar, Sip::Ubicacion
    can :nuevo, Sip::Ubicacion

    can :contar, Sivel2Gen::Caso
    can :buscar, Sivel2Gen::Caso
    can :lista, Sivel2Gen::Caso
    can :nuevo, Sivel2Gen::Presponsable
    can :nuevo, Sivel2Gen::Victima
    can :nuevo, Sivel2Gen::Victimacolectiva
    can :nuevo, Sivel2Gen::Combatiente
    if usuario && usuario.rol then
      case usuario.rol 
      when Ability::ROLANALI
        can :read, Heb412Gen::Doc
        can :read, Heb412Gen::Plantilladoc
        can :read, Heb412Gen::Plantillahcm
        can :read, Heb412Gen::Plantillahcr

        can :manage, Sip::Actorsocial
        can :manage, Sip::Persona

        can :manage, Sivel2Gen::Acto
        can :manage, Sivel2Gen::Actocolectivo
        can :read, Sivel2Gen::Caso
        can :new, Sivel2Gen::Caso
        can :nuevo, Sivel2Gen::Caso
        can [:update, :create, :destroy], Sivel2Gen::Caso
        
        can :read, ::Tipoamenaza
      when Ability::ROLADMIN
        
        can :manage, Heb412Gen::Doc
        can :manage, Heb412Gen::Plantilladoc
        can :manage, Heb412Gen::Plantillahcm
        can :manage, Heb412Gen::Plantillahcr

        can :manage, Sip::Actorsocial
        can :manage, Sip::Persona
        can :manage, Sip::Respaldo7z

        can :manage, Sivel2Gen::Acto
        can :manage, Sivel2Gen::Actocolectivo
        can :manage, Sivel2Gen::Caso
        can :read, Sivel2Gen::Victima

        can :manage, ::Usuario
        can :manage, :tablasbasicas
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end
end

