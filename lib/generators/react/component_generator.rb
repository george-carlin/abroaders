# Modified version of:
#
# https://github.com/reactjs/react-rails/blob/63d88c/lib/generators/react/component_generator.rb
#
# (The original version generated a single file under
# app/assets/javascripts/components.  My modified version generates a directory
# with the JSX file and a package.json file)
module React
  module Generators
    class ComponentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path '../../templates', __FILE__
      desc <<-DESC.strip_heredoc
      Description:
          Scaffold a react component into app/assets/javascripts/components.
          The generated component will include a basic render function and a PropTypes
          hash to help with development.

      Available field types:

          Basic prop types do not take any additional arguments. If you do not specify
          a prop type, the generic node will be used. The basic types available are:

          any
          array
          bool
          element
          func
          number
          object
          node
          shape
          string

          Special PropTypes take additional arguments in {}, and must be enclosed in
          single quotes to keep bash from expanding the arguments in {}.

          instanceOf
          takes an optional class name in the form of {className}

          oneOf
          behaves like an enum, and takes an optional list of strings that will
          be allowed in the form of 'name:oneOf{one,two,three}'.

          oneOfType.
          oneOfType takes an optional list of react and custom types in the form of
          'model:oneOfType{string,number,OtherType}'

      Examples:
          rails g react:component person name
          rails g react:component restaurant name:string rating:number owner:instanceOf{Person}
          rails g react:component food 'kind:oneOf{meat,cheese,vegetable}'
          rails g react:component events 'location:oneOfType{string,Restaurant}'
      DESC

      argument :attributes,
               type: :array,
               default: [],
               banner: "field[:type] field[:type] ..."

      REACT_PROP_TYPES = {
        "node" =>        'React.PropTypes.node',
        "bool" =>        'React.PropTypes.bool',
        "boolean" =>     'React.PropTypes.bool',
        "string" =>      'React.PropTypes.string',
        "number" =>      'React.PropTypes.number',
        "object" =>      'React.PropTypes.object',
        "array" =>       'React.PropTypes.array',
        "shape" =>       'React.PropTypes.shape({})',
        "element" =>     'React.PropTypes.element',
        "func" =>        'React.PropTypes.func',
        "function" =>    'React.PropTypes.func',
        "any" =>         'React.PropTypes.any',

        "instanceOf" => ->(type) do
          'React.PropTypes.instanceOf(%s)' % type.to_s.camelize
        end,

        "oneOf" => ->(*options) do
          enums = options.map { |k| "'#{k}'" }.join(',')
          'React.PropTypes.oneOf([%s])' % enums
        end,

        "oneOfType" => ->(*options) do
          types = options.map { |k| lookup(k.to_s, k.to_s).to_s }.join(',')
          'React.PropTypes.oneOfType([%s])' % types
        end,
      }.freeze

      def create_component_file
        dir = File.join('app/assets/javascripts/components', file_name.camelize.to_s)
        package_path = File.join(dir, "package.json")
        file_path    = File.join(dir, "#{file_name.camelize}.js.jsx")
        template("package.json.erb", package_path)
        template("component.js.jsx.erb", file_path)
      end

      private

      def parse_attributes!
        self.attributes = (attributes || []).map do |attr|
          options = ''
          options_regex = /(?<options>{.*})/

          name, type = attr.split(':')

          if (matchdata = options_regex.match(type))
            options = matchdata[:options]
            type = type.gsub(options_regex, '')
          end

          { name: name, type: lookup(type, options) }
        end
      end

      def self.lookup(type = "node", options = "")
        react_prop_type = REACT_PROP_TYPES[type]
        if react_prop_type.blank?
          react_prop_type = if type =~ /^[[:upper:]]/
                              REACT_PROP_TYPES['instanceOf']
                            else
                              REACT_PROP_TYPES['node']
                            end
        end

        options = options.to_s.gsub(/[{}]/, '').split(',')

        react_prop_type = react_prop_type.call(*options) if react_prop_type.respond_to? :call
        react_prop_type
      end
      private_class_method :lookup

      def lookup(type = "node", options = "")
        self.class.lookup(type, options)
      end
    end
  end
end
