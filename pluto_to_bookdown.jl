function pluto_to_bookdown(pluto)
    #Read the Pluto notebook
    str = open(f->read(f, String), pluto)
    #Convert the string file in a list, each element of  the list contains a Pluto cell
    list = split(str, "# ╔═╡ ")
    popfirst!(list)
    
    #The last element of the list contains the order in which the cells should be rendered
    cell_order_str = pop!(list)
    cell_order = split(cell_order_str,"# ")[2:end]
    
    # We obtain a list of the cells order
    for i in 1:length(cell_order)
        x =findfirst(r"[a-zA-Z0-9]",cell_order[i])[1]
        cell_order[i] = cell_order[i][x:x+35] 
    end
    #create a dictionary that match: cell Id => cell content
    cells_dict = Dict(list[1][1:36] => list[1][37:end])
    for cell in list
        cells_dict[cell[1:36]] = cell[37:end]
    end
    
    #Create de bookdown string that to store the bookdown content
    #All the bookdown will start the same way 
    bookdown = "# {TITLE}\n\n```{julia, echo=FALSE}\nusing Markdown\nusing InteractiveUtils\n```\n\n"
    
    # Iterate through all the Pluto cells in order and handle every cell depending of their content
    for id in cell_order
        
        cell = cells_dict[id]
        
        # Handle md pluto cells
        if contains(cell,"md\"")
        
            if contains(cell,"md\"\"\"")
                start = findfirst("md\"\"\"",cell)[end] + 1
                last = findlast("\"\"\"",cell)[1] - 1
            elseif contains(cell,"md\"")
                start = findfirst("md\"",cell)[end] + 1
                last = findlast("\"",cell)[1] - 1        
            end
        
            if contains(cell,"\";") 
            bookdown = bookdown * "```{julia, echo=FALSE} \r\n"* cell[start:last] * "```\n"
            else 
                bookdown = bookdown * cell[start:last] * "\n"
            end
        
        # Handle code cells
        else
        
            if contains(cell,"end;")
            bookdown = bookdown * "```{julia,results = FALSE} \n" * cell * "```\n"
            else
            bookdown = bookdown *  "```{julia} \r\n"* cell * "```\n"
            end
        
        end
    end
    
    #Create the Rmd file
    open(pluto[1:end-3]*".Rmd", "w") do f
        write(f, bookdown)
    end

    return pluto[1:end-3]*".Rmd" * " successfully created."
end        
    