# frozen_string_literal: true

module Toolbars
  class ProjectsService
    attr_reader :current_user

    include Canaid::Helpers::PermissionsHelper
    include Rails.application.routes.url_helpers

    def initialize(current_user, project_ids: [], project_folder_ids: [])
      @current_user = current_user
      @projects = current_user.current_team.projects.where(id: project_ids)
      @project_folders = current_user.current_team.project_folders.where(id: project_folder_ids)

      @items = @projects + @project_folders

      @single = @items.length == 1

      @item_type = if project_ids.blank? && project_folder_ids.blank?
                     :none
                   elsif project_ids.present? && project_folder_ids.present?
                     :any
                   elsif project_folder_ids.present?
                     :project_folder
                   else
                     :project
                   end
    end

    def actions
      return [] if @item_type == :none

      [
        restore_action,
        edit_action,
        access_action,
        move_action,
        export_action,
        archive_action,
        comments_action,
        activities_action,
        delete_folder_action
      ].compact
    end

    private

    def edit_action
      return unless @single

      if @items.first.is_a?(Project)
        project = @items.first

        return unless can_manage_project?(project)

        {
          name: 'edit',
          label: I18n.t('projects.index.edit_option'),
          icon: 'sn-icon sn-icon-edit',
          button_class: 'edit-btn',
          path: edit_project_path(project),
          type: :legacy
        }
      else
        project_folder = @items.first

        return unless can_create_project_folders?(project_folder.team)

        {
          name: 'edit',
          label: I18n.t('projects.index.edit_option'),
          icon: 'sn-icon sn-icon-edit',
          button_class: 'edit-btn',
          path: edit_project_folder_path(project_folder),
          type: :legacy
        }
      end
    end

    def access_action
      return unless @single

      return unless @item_type == :project

      project = @items.first

      return unless can_manage_team?(project.team) || can_read_project?(project)

      path = if can_manage_project_users?(project)
               edit_access_permissions_project_path(project)
             else
               access_permissions_project_path(project)
             end

      {
        name: 'access',
        label: I18n.t('general.access'),
        icon: 'sn-icon sn-icon-project-member-access',
        button_class: 'access-btn',
        path: path,
        type: 'remote-modal'
      }
    end

    def move_action
      return unless can_manage_team?(@items.first.team) &&
                    @items.all? { |item| item.is_a?(Project) ? can_read_project?(item) : true }

      {
        name: 'move',
        label: I18n.t('projects.index.move_button'),
        icon: 'sn-icon sn-icon-move',
        button_class: 'move-projects-btn',
        path: move_to_modal_project_folders_path,
        type: :legacy
      }
    end

    def export_action
      return unless @items.all? { |item| item.is_a?(Project) ? can_export_project?(item) : true }

      {
        name: 'export',
        label: I18n.t('projects.export_projects.export_button'),
        icon: 'sn-icon sn-icon-export',
        button_class: 'export-projects-btn',
        path: export_projects_modal_team_path(@items.first.team),
        type: :legacy
      }
    end

    def archive_action
      return unless @items.all? do |item|
        item.is_a?(Project) && can_archive_project?(item)
      end

      {
        name: 'archive',
        label: I18n.t('projects.index.archive_button'),
        icon: 'sn-icon sn-icon-archive',
        button_class: 'archive-projects-btn',
        path: archive_group_projects_path,
        type: :request,
        request_method: :post
      }
    end

    def restore_action
      return unless @items.all? do |item|
        item.is_a?(Project) && can_restore_project?(item)
      end

      {
        name: 'restore',
        label: I18n.t('projects.index.restore_button'),
        icon: 'sn-icon sn-icon-restore',
        button_class: 'restore-projects-btn',
        path: restore_group_projects_path,
        type: :request,
        request_method: :post
      }
    end

    def delete_folder_action
      return unless @items.all? do |item|
        item.is_a?(ProjectFolder) && can_delete_project_folder?(item)
      end

      {
        name: 'delete_folders',
        label: I18n.t('general.delete'),
        icon: 'sn-icon sn-icon-delete',
        button_class: 'delete-folders-btn',
        path: destroy_modal_project_folders_path(project_folder_ids: @items.map(&:id)),
        type: 'remote-modal'
      }
    end

    def comments_action
      return unless @single

      return unless @item_type == :project

      project = @items.first

      return unless can_read_project?(project)

      {
        name: 'comments',
        label: I18n.t('Comments'),
        icon: 'sn-icon sn-icon-comments',
        button_class: 'open-comments-sidebar',
        item_type: 'Project',
        item_id: project.id,
        type: :legacy
      }
    end

    def activities_action
      return unless @single

      return unless @item_type == :project

      project = @items.first

      return unless can_read_project?(project)

      activity_url_params = Activity.url_search_query({ subjects: { Project: [project] } })

      {
        name: 'activities',
        label: I18n.t('nav.label.activities'),
        icon: 'sn-icon sn-icon-activities',
        button_class: 'project-activities-btn',
        path: "/global_activities?#{activity_url_params}",
        type: :link
      }
    end
  end
end
