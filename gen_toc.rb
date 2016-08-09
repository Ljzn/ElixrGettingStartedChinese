# 根据翻译完的章节生成 gitbook 的 SUMMARY 目录结构

Dir['*.markdown'].map do |file|
  name = file.split('.')[0]
  number = name.split('_')[0]
  title = name.split('_')[1..-1].join(' ').capitalize
  [number.to_i,  "[#{title}](#{file})"]
end.sort_by do |number, _|
  number
end.each do |_, title|
  puts "* #{title}"
end
