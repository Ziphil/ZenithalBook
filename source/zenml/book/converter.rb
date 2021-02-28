# coding: utf-8


class Zenithal::Book::WholeBookConverter

  TYPESET_COMMAND = "cd %O & AHFCmd -pgbar -x 3 -d main.fo -p @PDF -o document.pdf 2> error.txt"
  OPEN_COMMANDS = {
    :sumatra => "SumatraPDF -reuse-instance %O/document.pdf",
    :formatter => "AHFormatter -s -d %O/main.fo"
  }

  def initialize(args)
    @typeset, @open_type = false, nil
    @dirs = {:output => "out", :document => "document", :template => "template"}
    options, rest_args = args.partition{|s| s =~ /^\-\w+$/}
    if options.include?("-t")
      @typeset = true
    end
    if options.include?("-os")
      @open_type = :sumatra
    elsif options.include?("-of")
      @open_type = :formatter
    end
    @rest_args = rest_args
  end

  def execute
    path = File.join(@dirs[:document], "manuscript", "main.zml")
    convert_normal(path)
    convert_typeset(path) if @typeset
    convert_open(path) if @open_type
  end

  def convert_normal(path)
    output_path = path.gsub(File.join(@dirs[:document], "manuscript"), @dirs[:output]).gsub(".zml", ".fo")
    parser = create_parser.tap{|s| s.update(File.read(path))}
    converter = create_converter.tap{|s| s.update(parser.run)}
    formatter = create_formatter
    File.open(output_path, "w") do |file|
      puts("")
      print_progress("Convert")
      formatter.write(converter.convert, file)
    end
  end

  def convert_typeset(path)
    progress = {:format => 0, :render => 0}
    command = TYPESET_COMMAND.gsub("%O", @dirs[:output])
    stdin, stdout, stderr, thread = Open3.popen3(command)
    stdin.close
    stdout.each_char do |char|
      if char == "." || char == "-"
        type = (char == ".") ? :format : :render
        progress[type] += 1
        print_progress("Typeset", progress)
      end
    end
    thread.join
  end

  def convert_open(path)
    command = OPEN_COMMANDS[@open_type].gsub("%O", @dirs[:output])
    stdin, stdout, stderr, thread = Open3.popen3(command)
    stdin.close
  end

  def print_progress(type, progress = nil)
    output = ""
    output << "\e[1A\e[K"
    output << "\e[0m\e[4m"
    output << type
    output << "\e[0m : \e[36m"
    output << "%3d" % (progress&.fetch(:format, 0) || 0)
    output << "\e[0m + \e[35m"
    output << "%3d" % (progress&.fetch(:render, 0) || 0)
    output << "\e[0m"
    puts(output)
  end

  def create_parser(main = true)
    parser = Zenithal::ZenithalParser.new("")
    parser.brace_name = "x"
    parser.bracket_name = "xn"
    parser.slash_name = "i"
    if main
      parser.register_macro("import") do |attributes, _|
        import_path = attributes["src"]
        import_parser = create_parser(false)
        import_parser.update(File.read(File.join(@dirs[:document], "manuscript", import_path)))
        document = import_parser.run
        import_nodes = (attributes["expand"]) ? document.root.children : [document.root]
        next import_nodes
      end
    end
    return parser
  end

  def create_converter
    converter = Zenithal::ZenithalConverter.new(nil)
    Dir.each_child(@dirs[:template]) do |entry|
      if entry.end_with?(".rb")
        binding = TOPLEVEL_BINDING
        binding.local_variable_set(:converter, converter)
        Kernel.eval(File.read(File.join(@dirs[:template], entry)), binding, entry)
      end
    end
    return converter
  end

  def create_formatter
    formatter = REXML::Formatters::Default.new
    return formatter
  end

  def output_dir=(dir)
    @dirs[:output] = dir
  end

  def document_dir=(dir)
    @dirs[:document] = dir
  end

  def template_dir=(dir)
    @dirs[:template] = dir
  end

end