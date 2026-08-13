return {
	["question"] = function(raw_args)
		question = raw_args[1]
		l1 = "A) " .. raw_args[2]
		line1 = string.gsub(l1, " ", "~")
		l2 = "B) " .. raw_args[3]
		line2 = string.gsub(l2, " ", "~")
		l3 = "C) " .. raw_args[4]
		line3 = string.gsub(l3, " ", "~")
		l4 = "D) " .. raw_args[5]
		line4 = string.gsub(l4, " ", "~")
		correct = raw_args[6]

		if correct == "a" then
			cor_ans = l1
		elseif correct == "b" then
			cor_ans = l2
		elseif correct == "c" then
			cor_ans = l3
		elseif correct == "d" then
			cor_ans = l4
		end

		label = math.random(1, 10000)
		label2 = math.random(1, 10000)

		if quarto.doc.is_format("pdf") then
			block = pandoc.RawBlock(
				"tex",
				"\\begin{tcolorbox}[enhanced jigsaw, opacitybacktitle=0.6, coltitle=black, opacityback=0, colframe=gvblue, leftrule=.75mm, bottomtitle=1mm, left=2mm, rightrule=.15mm, arc=.35mm, breakable, toprule=.15mm, bottomrule=.15mm, titlerule=0mm, title=\\textcolor{gvblue}{\\faQuestion}\\hspace{0.5em}{"
					.. question
					.. "}, toptitle=1mm, colback=white, colbacktitle=gvblue!10!white]"
					.. "\\ExplSyntaxOn\\begin{tabular}{cl}"
					.. "\\pdffield_radio:n{name="
					.. label
					.. ",value=button1,default} & "
					.. line1
					.. " \\\\"
					.. " \\pdffield_radio:n{name="
					.. label
					.. ",value=button2} & "
					.. line2
					.. " \\\\"
					.. " \\pdffield_radio:n{name="
					.. label
					.. ",value=button3} & "
					.. line3
					.. " \\\\"
					.. " \\pdffield_radio:n{name="
					.. label
					.. ",value=button4} & "
					.. line4
					.. " \\end{tabular} \\\\"
					.. " \\\\"
					.. "Explanation: \\\\"
					.. "\\TextField[width=\\textwidth,height=0.5in,setFf={Multiline},unsetFf=Comb]{"
					.. label2
					.. "}"
					.. "\\ExplSyntaxOff\\end{tcolorbox}\\vspace{3mm}"
			)
		end

		if quarto.doc.is_format("revealjs") then
			block = pandoc.RawBlock(
				"html",
				"<ul><li class='fragment highlight-current-custom'><b>Question: "
					.. question
					.. "</b></li><li>"
					.. l1
					.. "</li><li>"
					.. l2
					.. "</li><li>"
					.. l3
					.. "</li><li>"
					.. l4
					.. "</li>"
			)
		end

		if quarto.doc.is_format("html") then
			block = pandoc.RawBlock(
				"html",
				"<ul class='fragment highlight-current-custom'><li><b>Question: "
					.. question
					.. "</b></li><ul><li>"
					.. l1
					.. "</li><li>"
					.. l2
					.. "</li><li>"
					.. l3
					.. "</li><li>"
					.. l4
					.. "</li></ul></ul>"
			)
		end

		return block
	end,
}
