function error_404()
	error_page("Page not found", "This website does not exist.")
end

function error_9001()
	error_page("Page blocked", "Your employer blocked this page.\n\nPlease contact your network\nadministrator if in doubt.")
end

function error_page(title, text)
	local page_width, page_length = guiGetSize(internet_pane, false)
	setPageTitle("Error - " .. title)

	bg = guiCreateStaticImage(0,0,page_width,page_length,"websites/colours/1.png",false,internet_pane)
	guiSetEnabled(bg, false)
	
	local s = 288
	local l, t = (page_width - s)/2, (page_length - s)/2
	local image = guiCreateStaticImage(l, t, s, s,"websites/images/dinosaur.png",false,bg)
	guiScrollPaneSetScrollBars(internet_pane, false, false)
end


