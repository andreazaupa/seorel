# encoding: utf-8
module Seorel
  module Model
    module Base
      def seorelify(*args)
        extend  ClassMethods
        include InstanceMethods

        cattr_accessor :seorel_title_field, :seorel_description_field, :seorel_image_field

        if args[0].class.name == 'Hash'
          class_variable_set '@@seorel_title_field',       args[0][:title]
          class_variable_set '@@seorel_description_field', args[0][:description] || args[0][:title]
          class_variable_set '@@seorel_image_field',       args[0][:image]
        else
          class_variable_set '@@seorel_title_field',       args[0]
          class_variable_set '@@seorel_description_field', args[1] || args[0]
          class_variable_set '@@seorel_image_field',       args[2]
        end

        unless ::Seorel.config.tableless
          has_one :seorel, as: :seorelable, dependent: :destroy, class_name: 'Seorel::Seorel'
          accepts_nested_attributes_for :seorel, allow_destroy: true

          delegate :title, :title?, :description, :description?, :image, :image?,
            to: :seorel, prefix: :seorel, allow_nil: true

          before_save :set_seorel
        else
          %w(seorel_title seorel_description seorel_image).each do |m|            
            define_method(m) do
              self.send(self.class.send("seorel_#{m.to_s.gsub("seorel_", "")}_field"))
            end
          end
        end
      
      end
    end
  end
end
