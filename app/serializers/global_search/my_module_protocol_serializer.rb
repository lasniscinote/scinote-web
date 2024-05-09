# frozen_string_literal: true

module GlobalSearch
  class MyModuleProtocolSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :code, :created_at, :updated_at, :team, :experiment, :my_module, :archived, :url

    def name
      object.name.presence || I18n.t('search.index.untitled_protocol')
    end

    def team
      {
        name: object.team.name,
        url: dashboard_path(team: object.team)
      }
    end

    def experiment
      archived = object.my_module.experiment.archived_branch?
      {
        name: object.my_module.experiment.name,
        url: my_modules_experiment_path(object.my_module.experiment.id, view_mode: view_mode(archived)),
        archived: archived
      }
    end

    def my_module
      archived = object.my_module.archived_branch?
      {
        name: object.my_module.name,
        url: protocols_my_module_path(object.my_module.id, view_mode: view_mode(archived)),
        archived: archived
      }
    end

    def created_at
      I18n.l(object.created_at, format: :full_date)
    end

    def archived
      object.my_module.archived_branch?
    end

    def updated_at
      I18n.l(object.updated_at, format: :full_date)
    end

    def url
      protocols_my_module_path(object.my_module.id, view_mode: view_mode(archived))
    end

    private

    def view_mode(archived)
      archived ? 'archived' : 'active'
    end
  end
end
