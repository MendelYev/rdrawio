# rdrawio

This package allows Draw.io chart generation from R data and Draw.io templates.

## Installation

Install the package with :

~~~~
# execute install.packages("devtools") if needed
library("devtools")
install_github("MendelYev/drawio")
~~~~

Install desktop version of drawio : <https://about.draw.io/integrations/#integrations_offline>

## Usage

### Draw.io template

Under draw.io, generate a chart with placeholders using %my_variable% syntax inside your labels.
Activate placeholders handling for all your elements using them (Ctrl+M for each --> activate placeholders)

Then, you need to list all your variables :
- select all your chart elements (CTRL+A)
- group them (CTRL+G)
- edit the properties of the group (with the group still selected : CTRL+M)
- list all of your variable names (without "%") as properties. You can leave their values empty since they will be filled by the R package

Save the .drawio file, this will be your template.

### Using the template under R

With a template using these placeholders : %nb_people%, %group_name%, %result%
Generate according values under R inside a list with the same attribute names :

~~~~
data <- list(
  nb_people = 243,
  group_name = "placebo",
  result = "Success!"
)
~~~~

You can generate a chart with these values based on a template with adapted placeholders like this :

~~~~
library(rdrawio)
generate_drawio(
  template = "path/to/template.drawio", 
  meta = data,
  output = "path/to/output.png"
)
~~~~

Currently, rdrawio support PNG, JPG, SVG and PDF export. The format will be automatically detected from the output extension.

The package will look for drawio dekstop executable in "C:/Program Files/draw.io/draw.io.exe" by default.
You can change its path by filling it as a parameter:

~~~~
library(rdrawio)
generate_drawio(
  template = "path/to/template.drawio", 
  meta = data,
  output = "path/to/output.png",
  drawio_path = "alternative/path/draw.io.exe"
)
~~~~

## Limitations

This package has only been tested under Windows 7 and Windows 10 (64 bits). Feedbacks are welcome for other OS.
