module Coveralls
  class ServiceBase

    def ci?
      @@possible_ci_envs.any?{ |name| ENV[name] }
    end

    class << self
      def inherited(klass)
        (@@possible_ci_envs || = []).push klass::ENV_VAR
      end
    end
  end
end