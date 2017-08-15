#! /usr/bin/ruby
# coding: utf-8

# $KCODE = "EUC"

# ★ 章タイトル
# ☆ 章番号なしタイトル
#《.*》 節タイトル
# ■ 項タイトル
# Fig:label:caption  file-name="label.eps"
# #ref{label}

def sub_texkey l
  l = l.gsub( /\\/, "\\\\\\\\" )
  l = l.gsub( /#ref/, '\ref' )
  l = l.gsub( /_/, '\\_' )
  l = l.gsub( /#/, '\\#' )
  l = l.gsub( /\$/, '\\$' )
  l = l.gsub( /\&/, '\\\&' )
  return l
end

def texnize fn

  unget_l = nil

  print "% #{fn}\n"

  f = File.open( fn, "r" )
  while f.eof? == false

    # unget したものがあれば、そちらを読み出す
    if unget_l != nil then
      l = unget_l
      unget_l = nil
    else
      l = f.gets
    end

    # verbatim (sub_texkey する前に処理)
    if l =~ /^[ \t][^・]/ then

      print "\\begin{verbatim}\n"
      print l
      while 1
        l = f.gets
        if l =~ /^[ \t][^・]/ then
          print l
        else
          print "\\end{verbatim}\n"
          unget_l = l
          break
        end
      end
      next

    end

    l = sub_texkey l

    # itemize
    if l =~ /^・/ || l =~ /^ ・/ then
      print "\\begin{itemize}\n"
      l = l.sub( /・/, "" )
      print "\\item #{l}\n"

      while 1
        l = f.gets

        if l =~ /^・/ || l =~ /^ ・/ then
          l = sub_texkey l
          l = l.sub( /・/, "" )
          print "\\item #{l}\n"
          next
        else
          print "\\end{itemize}\n"
          unget_l = l
          break
        end
      end
      next
    end
    # itemize 終り

    # enumerate
    if l =~ /^[0-9]+\./ then
      print "\\begin{enumerate}\n"
      l = l.sub( /[0-9]+\./, "" )
      print "\\item #{l}\n"

      while 1
        l = f.gets

        if l =~ /^[0-9]+\./ then
          l = sub_texkey l
          l = l.sub( /[0-9]+\./, "" )
          print "\\item #{l}\n"
          next
        else
          print "\\end{enumerate}\n"
          unget_l = l
          break
        end
      end
      next
    end
    # enumerate 終り

    # tabular 始まり
    if l=~ /^\|/ then
      # l = l.sub( /^\|/, "" )        # '|' の置換がうまくいかないので、下1行で実現
      l = l[1..9999]   # 先頭を取り除く
      column = "|l"
      while 1
        if l =~ /\|/ then
          # l = l.sub( /\\|/, '\&' )  # '|' の置換がうまくいかないので、下2行で実現
          nth = l.index( '|' )
          l[nth]='&'
          column += "|l"
        else
          break
        end
      end
      column += "|"
        
      print "\\begin{tabular} [htb] {#{column}} \\hline\n"
      print "#{l} \\\\ \\hline\n"

      while 1
        l = f.gets

        if l =~ /^\|/ then
          l = sub_texkey l

          # l = l.sub( /^\|/, "" )     # '|' の置換がうまくいかないので、下1行で実現
          l = l[1..9999]   # 先頭を取り除く

          # l = l.gsub( /^\|/, "&" )  # '|' の置換がうまくいかないので、下7行で実現
          while 1
            nth = l.index( '|' )
            if nth == nil then
              break
            end
            l[nth]='&'
          end

          print "#{l} \\\\ \\hline\n"
          next
        else
          print "\\end{tabular}\n"
          unget_l = l
          break
        end
      end
      print "\\vspace{3mm}\\\\\n"
      next
    end
    # tabular 終り

    # Figure
    if l =~ /^Fig:/ then
      fig = l.split ':'
      label   = fig[1]
      caption = fig[2]
      width   = fig[3]
      if width == nil then
        width = "8cm"
      end
      print <<EOT
\\begin{figure}[ht]
\\begin{center}
%\\includegraphics*[scale=0.8]{Fig/#{label}.eps}
% \\includegraphics*[width=12cm]{Fig/#{label}.eps}
% \\includegraphics*[width=8cm,height=5cm]{Fig/#{label}.eps}
% \\includegraphics*[width=8cm]{Fig/#{label}.eps}
\\includegraphics*[width=#{width}]{Fig/#{label}.eps}
% \\epsfile{file=Fig/#{label}.eps,width=0.5\hsize}
\\caption{#{caption}}
\\label{#{label}}
\\end{center}
\\end{figure}
EOT
      next
    end

    if l =~ /^★/ then         # 章タイトル
      l = l.gsub( /★(.*)\n/, '\1' )
      print_chap_head( l, true )
    elsif l =~ /^☆/ then         # 章番号なしタイトル
      l = l.gsub( /☆(.*)\n/, '\1' )
      print_chap_head( l, false )
    elsif l =~ /^《.*》/ then  # 節タイトル
      l = l.gsub( /^《(.*)》.*\n/, '\1' )
      print_sect_head l
    elsif l =~ /^■/ then      # 項タイトル
      l = l.gsub( /■(.*)\n/, '\1' )
      print_subsect_head l
    else                       # 一般行
      print l
    end
#  }
  end
  print <<EOT

EOT
  f.close
end


def print_preamble
  print <<EOT
\\documentclass[]{jbook}
\\usepackage{graphicx}
\\usepackage[dvipdfmx,bookmarks=true,bookmarksnumbered=true,%
bookmarkstype=toc]{hyperref}
\\usepackage{pxjahyper}
% \\AtBeginDvi{\\special{pdf:tounicode UTF-UCS2}}
%\\usepackage[bookmarksnumbered=true,dvipdfm]{hyperref}

% プリアンブル
\\title{組込みコンポーネントシステム TECS}
\\author{大山 博司} 
\\date{2017年7月30日}

\\begin{document}

% タイトルの表示
\\maketitle

\\pagenumbering{roman}

% 目次
\\tableofcontents

\\pagenumbering{arabic}

EOT
end

def print_chap_head( chap_name, b_chap_num )
  if chap_name == "Appendix"
    print <<EOT
\\appendix
EOT
    return
  end

  if b_chap_num
    print <<EOT
\\chapter{#{chap_name}}
EOT
  else
    print <<EOT
\\chapter*{#{chap_name}}
EOT
  end
end

def print_sect_head sect_name
  print <<EOT
\\section{#{sect_name}}
EOT
end

def print_subsect_head sect_name
  print <<EOT
\\subsection{#{sect_name}}
EOT
end

def print_postamble
  print <<EOT
\\end{document}

EOT
end
##

print_preamble
#files = Dir.glob( "*/*.txt" )
#files.each{ |fn|
ARGV.each { |fn|
  texnize fn
}
print_postamble
