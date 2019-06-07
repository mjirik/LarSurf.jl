using EzXML

# <svg version="1.0" id="Livello_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 283.5 283.5" enable-background="new 0 0 283.5 283.5" xml:space="preserve">

fn = "test.xml"
# fn = "lar4.svg"
println(isfile(fn))
doc = EzXML.readxml(fn)
# Select <a/> links that contain a non-blank text node.
# links = findall("//book/@category", doc)
links = findall("//path/@d", doc)
# links = findall("//path/@d", doc)
println(links)
# width = ndigits(length(links))
for (i, link) in enumerate(links)
#     println(lpad(i, width), ": ", strip(nodecontent(link)), " -- ", link["href"])
    println(": ", strip(nodecontent(link)))
end

# [strip(nodecontent(link)) for link in links]
# links = findall("//year/@tag", doc)
# links = findall("//book[@category and normalize-space(text()) != '']", doc)
