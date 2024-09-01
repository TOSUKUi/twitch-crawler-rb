module Crawler
  class RunnerBase
    def initialize
      %w[before doing].each do |status|
        instance_variable_set(:"@#{status}_folder", "#{save_folder_root}/#{status}")
        FileUtils.mkdir_p("#{save_folder_root}/#{status}")
      end
    end

    def parse
      paths = Dir.glob("#{@before_folder}/*.json")
      FileUtils.move(paths, @doing_folder)
      paths.each do |path|
        path.gsub!('before', 'doing')
        parse_file(path)
        File.unlink(path)
      rescue StandardError => e
        logger.error(e)
      end
    end

    protected

    def parse_file(doing_path)
      raise NotImplementedError
    end

    def save_folder_root
      raise NotImplementedError
    end
  end
end
