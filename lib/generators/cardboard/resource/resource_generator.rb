module Cardboard
  module Generators
    class ResourceGenerator < Rails::Generators::Base
      desc "Scaffold a Cardboard resource"
      argument :resource_name, type: :string
      #TODO: option for haml
      class_option  :markup, type: :string, default: "erb", desc: "Erb and slim available"
      class_option  :overwrite, type: :boolean, default: false , desc: "Use to overwrite default views. You will not get updates when you regenerate views."

      def self.source_root
        @_cardboard_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def validate_model_exists
        fields
      rescue Exception => e
        raise "Model #{singular_table_name.classify} does not exist, or there's no database. Try running `rails g model #{singular_table_name.classify}`"
      end

      def generate_controller_file
        template "admin_controller.rb", "app/controllers/#{controller_name}.rb"
      end

      def generate_view_files
        empty_directory File.join(view_path, plural_table_name)
        template "#{options.markup}/index.html.#{options.markup}", "#{view_path}/#{plural_table_name}/index.html.#{options.markup}"
        template "#{options.markup}/_fields.html.#{options.markup}", "#{view_path}/#{plural_table_name}/_fields.html.#{options.markup}"
        template "#{options.markup}/edit.html.#{options.markup}", "#{view_path}/#{plural_table_name}/edit.html.#{options.markup}"
        template "#{options.markup}/new.html.#{options.markup}", "#{view_path}/#{plural_table_name}/new.html.#{options.markup}"
      end

      private

      def view_path
        if options.overwrite
          "app/views/cardboard"
        else
          "vendor/cardboard/views/cardboard"
        end
      end

      def fields
        @_fields ||= singular_table_name.classify.constantize.column_names
          .reject do |column_name|
            column_name.empty? || column_name == "created_at"
          end
      end

      def plural_table_name
        @_plural_table_name ||= singular_table_name.pluralize
      end

      def singular_table_name
        @_singular_table_name ||= resource_name.to_s.singularize.underscore
      end


      def controller_name
        "cardboard/#{plural_table_name}_controller"
      end
    end
  end
end
