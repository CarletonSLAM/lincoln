module HELP
  module_function

  def help
    lines = []
    pp @sections
    @sections.each do |section, helper|
      lines << "*#{section}*\n#{helper.help}\n"
    end
    pp lines.join("\n")
    yield lines.join("\n")
  end

  @sections = {
    'AWS' => EC2
  }
end
