# frozen_string_literal: true

require_relative "grading_checker/version"
require "rainbow"
require "yaml"
require "pathname"
require "ripper"

module GradingChecker

    class Error < StandardError; end

    class FileManager
        attr_reader :root_path

        def initialize(root_path)
            @root_path = Pathname.new(root_path)
        end

        def load_yaml(file_path)
            return {} unless file_path.exist?

            YAML.load_file(file_path, aliases: true) || {}
        rescue StandardError => e
            abort("Error loading YAML file: #{file_path}\n#{e.message}")
        end

        def find_grading_ymls
            @root_path.find.select { |path| path.file? && path.basename.to_s == "grading.yml" }
        end

        def find_submit_ymls
            @root_path.find.select { |path| path.file? && path.basename.to_s == "submit.yml" }
        end

        def merge_configs(grades1, grades2)
            first_without_grades = grades1.reject { |k, _| %w[templates grades calculation].include?(k) }
            second_without_grades = grades2.reject { |k, _| %w[templates grades calculation].include?(k) }

            merged_grades = (grades1["grades"] || {}).merge(grades2["grades"] || {})
            merged_calculation = (grades1["calculation"] || {}).merge(grades2["calculation"] || {})
            merged_rest = first_without_grades.merge(second_without_grades)
            merged_rest["grades"] = merged_grades
            merged_rest["calculation"] = merged_calculation

            merged_rest
        end
    end

    class GradingYAMLValidator
        VALID_GRADE_TYPES = %w[pass float integer points].freeze
        VALID_SUBGRADE_TYPES = %w[integer pass boolean float].freeze
        DEFAULT_GRADE_TYPE = "float"

        GREEN = Rainbow(":)").green
        RED = Rainbow(":(").red

        def initialize(file_manager)
            @file_manager = file_manager
        end

        def validate_root_grading_config!
            @root_config = @file_manager.load_yaml(@file_manager.root_path.join("grading.yml"))
            validate_yaml_structure(@root_config, "grading.yml")
        end

        def validate_subdir_configs!
            @file_manager.find_grading_ymls.each do |path|
                next if path.dirname == @file_manager.root_path

                merged_config = @file_manager.merge_configs(@root_config, @file_manager.load_yaml(path))
                validate_yaml_structure(merged_config, path.relative_path_from(@file_manager.root_path).to_s)
            end
        end

        def validate_duplicate_submit_names!
            submit_names = Hash.new { |hash, key| hash[key] = [] }

            submit_ymls = @file_manager.find_submit_ymls
            submit_ymls.each do |path|
                submit_config = @file_manager.load_yaml(path)
                next unless submit_config.is_a?(Hash) && submit_config.key?("name")

                submit_names[submit_config["name"]] << path.relative_path_from(@file_manager.root_path).to_s
            end

            duplicate_submits = submit_names.select { |_, paths| paths.size > 1 }

            if duplicate_submits.any?
                report_error("duplicate submit names found in submit.yml:")
                duplicate_submits.each do |name, paths|
                    puts "  - #{name} appears in: #{paths.join(", ")}"
                end
                exit(1)
            else
                report_success("no duplicate submit names found in #{submit_ymls.size} submit.yml configs")
            end
        end

        def validate_yaml_structure(config, file_name)
            validate_section(config, "templates") do |templates|
                templates.each do |key, value|
                    unless value.is_a?(Hash) && value.key?("type")
                        report_error("template #{key} must be a hash with a 'type' key")
                        exit(1)
                    end
                end
            end

            validate_section(config, "grades") do |grades|
                grades.each do |grade, details|
                    grade_type = details["type"] || DEFAULT_GRADE_TYPE
                    unless VALID_GRADE_TYPES.include?(grade_type)
                        report_error("grade #{grade} has an invalid type: #{grade_type}. Must be one of #{VALID_GRADE_TYPES.join(", ")}")
                        exit(1)
                    end
                end
            end

            validate_module_definitions(config)

            validate_section(config, "calculation") do |calculation|
                calculation.each do |calc, details|
                    unless details.is_a?(Hash)
                        report_error("calculation #{calc} must be a hash of weighted components")
                        exit(1)
                    end
                end
            end

            report_success(file_name)
        end

        def validate_section(config, section)
            return unless config.key?(section)

            unless config[section].is_a?(Hash)
                report_error("#{section.capitalize} section must be a hash")
                exit(1)
            end
            yield(config[section]) if block_given?
        end

        def validate_module_definitions(config)
            return unless config.is_a?(Hash)

            grade_keys = config["grades"]&.keys || []

            config.each do |key, value|
                next unless value.is_a?(Hash) && value.key?("submits")

                unless value["submits"].is_a?(Hash)
                    report_error("module definition #{key} has an invalid submits section: it must be a hash.")
                    exit(1)
                end

                value["submits"].each_key do |submit_key|
                    unless grade_keys.include?(submit_key)
                        report_error("module definition #{key} references a non-existent grade: #{submit_key}")
                        exit(1)
                    end
                end
            end
        end

        def report_success(message)
            puts "#{GREEN} #{message}"
        end

        def report_error(message)
            puts "#{RED} #{message}"
        end
    end

end
