return {
	["important"] = function(raw_args)
		text = raw_args[1]

		if quarto.doc.is_format("pdf") then
			block = pandoc.RawBlock(
				"tex",
				"\\begin{tcolorbox}[enhanced jigsaw, opacitybacktitle=0.6, coltitle=black, opacityback=0, colframe=gvblue, leftrule=.75mm, bottomtitle=1mm, left=2mm, rightrule=.15mm, arc=.35mm, breakable, toprule=.15mm, bottomrule=.15mm, titlerule=0mm, title=\\textcolor{gvblue}{\\faExclamationCircle}\\hspace{0.5em}{Important}, toptitle=1mm, colback=white, colbacktitle=gvblue!10!white]"
					.. text
					.. "\\end{tcolorbox}\\vspace{3mm}"
			)
		end

		if quarto.doc.is_format("revealjs") then
			block = pandoc.RawBlock(
				"html",
				"<ul><li class='fragment highlight-current-custom'><b>Important: " .. text .. "</b></ul></li>"
			)
		end

		if quarto.doc.is_format("html") then
			block = pandoc.RawBlock(
				"html",
				"<ul><li class='fragment highlight-current-custom'><b>Important: " .. text .. "</b></ul></li>"
			)
		end

		return block
	end,
}
