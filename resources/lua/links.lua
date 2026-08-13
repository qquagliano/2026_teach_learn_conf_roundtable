function Link(el)
	text = pandoc.utils.stringify(el)
	target = el.target

	if quarto.doc.is_format("pdf") then
		if
			string.find(target, "http")
			or string.find(target, ".com")
			or string.find(target, "www")
			or string.find(target, ".org")
			or string.find(target, ".edu")
			or string.find(target, "tel:")
			or string.find(target, "mailto:")
		then
			el = pandoc.RawInline("tex", "\\href{" .. el.target .. "}{\\dotuline{" .. text .. "}}")
		else
			el = pandoc.RawInline(
				"tex",
				"\\hyperref[" .. string.gsub(el.target, "#", "") .. "]{\\dotuline{" .. text .. "}}"
			)
		end
	end

	if quarto.doc.is_format("revealjs") then
		el.classes = table.insert(el.classes, "dotted")
	end

	if quarto.doc.is_format("html") then
		el.classes = table.insert(el.classes, "dotted")
	end

	return el
end
