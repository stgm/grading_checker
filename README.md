# GradingChecker

GradingChecker is a tool designed to validate grading configuration files (`grading.yml` and `submit.yml`) in a given directory.
It is intended to be used on courseware repositories for the [Course Site](https://github.com/stgm/course-site).
This tool ensures that submission names are unique and that grading configurations follow the expected structure.

## Features

- Checks for duplicate submission names in `submit.yml` files.
- Validates the structure of `grading.yml` files in the root and subdirectories.
- Reports errors and provides clear feedback on misconfigurations.
- Supports a simple command-line interface.

## Installation

To install the gem:

```sh
gem install grading_checker
```

## Usage

Run the command to validate grading configurations:

```sh
grading_checker [DIRECTORY]
```

- If no directory is provided, the current directory is used.
- The tool will scan for `grading.yml` and `submit.yml` files and report any issues.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grading_checker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stgm/grading_checker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GradingChecker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stgm/grading_checker/blob/main/CODE_OF_CONDUCT.md).
