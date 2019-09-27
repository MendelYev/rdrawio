#' Generate a drawio document based on a template and metadata
#'
#' Your template must contains placeholders like %placeholder%
#' (see: https://desk.draw.io/support/solutions/articles/16000051979-how-to-work-with-placeholders-).
#' Placeholders must be activated for your objects (CTRL+M).
#' This function will populate your placeholders based on the meta argument and the template file,
#' and will export the resulting chart in a desired format.
#'
#' Draw.io desktop version is required to generate exports.
#' It is assumed to be 'C:/Program Files/draw.io/draw.io.exe' but it can be changed with drawio_path argument
#'
#' @param template The path to the drawio template
#' @param meta A liste containing metadata
#' @param output A path for the export file (allowed formats : png, jpg, svg, pdf)
#' @param drawio_path The path to draw.io executable
#'
#' @author Jeremy Pasco
#'
#' @examples
#' \dontrun{
#' meta <- list('color'='red', 'age'=75)
#' generate_drawio('path/to/template.drawio', meta, 'path/to/export.png')
#' }
#'
#' @importFrom V8 new_context
#'
#' @export
generate_drawio <- function(template, meta, output=NULL, drawio_path='C:/Program Files/draw.io/draw.io.exe') {

  xml <- read_drawio(template)

  ct <- new_context()
  ct$source(system.file("extdata", "pako.min.js", package = "rdrawio"))
  ct$source(system.file("extdata", "deflate.js", package = "rdrawio"))

  diagram <- inflate(ct, xml)
  diagram <- apply_meta(diagram, meta)
  diagram <- deflate(ct, diagram)
  write_drawio(template, xml, diagram)

  export_drawio(template, output, drawio_path)
}

#' @importFrom xml2 read_xml
read_drawio <- function(template){

  xml <- read_xml(template)

}

#' @importFrom xml2 xml_text
#' @importFrom rvest xml_node
inflate <- function(ct, xml){

  diagram <- xml_text(xml_node(xml, "diagram"))
  ct$assign("diagram", diagram)
  ct$eval("var res = decode(diagram)")
  return(ct$get("res"))

}

#' @importFrom stringr str_replace_all
apply_meta <- function(diagram, meta){

  n <- names(meta)
  for(i in seq_along(meta)){
    diagram <- str_replace_all(diagram, paste0(n[[i]], '=".*?"'), paste0(n[[i]], '="', meta[[i]], '"'))
  }

  return(diagram)
}

deflate <- function(ct, diagram){

  ct$assign("diagram", diagram)
  ct$eval("var xml = encode(diagram)")
  return(ct$get("xml"))

}

#' @importFrom xml2 xml_text xml_text<- write_xml
#' @importFrom rvest xml_node
write_drawio <- function(template, xml, diagram){

  node <- xml_node(xml, "diagram")
  xml_text(node) <- diagram
  write_xml(xml, template)

}

#' @importFrom stringr str_match str_remove
export_drawio <- function(template, output, drawio_path){

  if(is.null(output)){
    return
  }

  tryCatch({
    format <- str_match(output, '\\.(.+)')[1, 2]
  }, error=function(e) {
    stop("Cannot guess type from export filename")
  })

  formats <- c("png", "jpg", "svg", "pdf")

  if(!(format %in% formats)){
    stop(paste0("Cannot export in ", format, " format"))
  }

  new_file <- str_remove(template, "\\.drawio")

  system(paste0('"', drawio_path, '" -x -f ', format, ' "', template, '" -o "', output, '"'))
}
