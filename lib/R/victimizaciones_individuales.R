# Victimizaciones individuales
# Autores: Andres Mauricio Galeano agaleano@cinep.org.co 
#   y Vladimir Támara  vtamara@pasosdeJesus.org

# Nomenclatura: shiny usa CamelCase comenzando en minúscula
# R usa más _
# Usamos más _
# Variables que podamos poner en español, las ponemos en español

print("** victimizaciones individuales")
if(!require(shiny)){
  install.packages("shiny", repos = "https://www.icesi.edu.co/CRAN/")
}
library(shiny)
if(!require(ggplot2)){
  install.packages("ggplot2", repos = "https://www.icesi.edu.co/CRAN/")
}
library(ggplot2)
if(!require(rio)){
  install.packages("rio", repos = "https://www.icesi.edu.co/CRAN/")
}
library(rio)
if(!require(plyr)){
  install.packages("plyr", repos = "https://www.icesi.edu.co/CRAN/")
}
library(plyr)
if(!require(dplyr)){
  install.packages("dplyr", repos = "https://www.icesi.edu.co/CRAN/")
}
library(dplyr)
if(!require(svglite)){
  install.packages("svglite", repos = "https://www.icesi.edu.co/CRAN/")
}
library(svglite)
if(!require(shinydashboard)){
  install.packages("shinydashboard", repos = "https://www.icesi.edu.co/CRAN/")
  library(shinydashboard)
}
if(!require(shinyWidgets)){
  install.packages("shinyWidgets", repos = "https://www.icesi.edu.co/CRAN/")
  library(shinyWidgets)
}

print("** dependencias completas")


# Preparación de datos
print(rutacsv)
tabla <- import(rutacsv)
tabla$sexonac <- factor(tabla$sexonac)
tabla$fecha <- as.Date(tabla$fecha)
tabla$categoria_rotulo <- factor(tabla$categoria_rotulo)
tabla$departamento <- factor(tabla$departamento)
tablasub <- subset(tabla, select  = 
  c(fecha, sexonac, departamento, categoria_rotulo))
tablasub <- dplyr::rename(tablasub, SexoNac=sexonac, Fecha=fecha,
  Departamento=departamento,Categoria=categoria_rotulo)

minfecha = min(tablasub$Fecha)
print(minfecha)
maxfecha = max(tablasub$Fecha)
print(maxfecha)

print("Por generar interfaz de usuario")
# Interfaz de usuario
interfaz <- dashboardPage(skin = "blue",
  dashboardHeader(disable = T),
  dashboardSidebar(
    dateRangeInput(inputId = "rango",
      label = "Rango de fechas de la victimización",
      start = minfecha,
      end = maxfecha,
      format = "yyyy-mm-dd"),
    varSelectInput("var", "Seleccione variable",
      data = tablasub[,2:4],
      multiple = F,
      selected = NULL,
      selectize = T),
    pickerInput("sexonac", "Sexos incluidos",
      choices = levels(tablasub$SexoNac),
      multiple = T,
      selected = levels(tablasub$SexoNac),
      choicesOpt = list(
        style=rep(("color: black; background:lightgrey;"),50))),
    pickerInput("categoria_rotulo", "Categorias de violencia incluidas",
      choices = levels(tablasub$Categoria),
      multiple = T,
      selected = levels(tablasub$Categoria),
      options = pickerOptions(
        actionsBox = T,
        liveSearch = T,
        noneSelectedText = "Seleccione:",
        noneResultsText = "Valor no encontrado",
        virtualScroll = T),
      choicesOpt = list(
        style=rep(("color: black; background: lightgrey;"),50))),
    pickerInput("departamento", "Departamentos incluidos",
      choices = levels(tablasub$Departamento),
      multiple = T,
      selected = levels(tablasub$Departamento),
      options = pickerOptions(
        actionsBox = T,
        liveSearch = T,
        noneSelectedText = "Seleccione:",
        noneResultsText = "Valor no encontrado",
        virtualScroll = T),
      choicesOpt = list(
        style=rep(("color: black; background: lightgrey;"),50)))
    ),
  dashboardBody(
    tags$head(tags$style(HTML('
	.info-box { min-height: 45px; width: 300px;} 
	.info-box-icon {height: 45px; line-height: 45px;} 
	.info-box-content {padding-top: 0px; padding-bottom: 0px;}
	.skin-blue .left-side, 
	.skin-blue .main-sidebar, 
	.skin-blue .wrapper {
	  background-color: #bf1b28;
	}
	'))),
    fluidRow(infoBoxOutput("vict_n")),
    fluidRow(
      box(
	width = 12,
	title = "Serie de tiempo", 
        color = "red", 
        solidHeader = T,
        collapsible = T,
        plotOutput("graficar_serie"),
        downloadButton("descargar_serie_SVG", "SVG"),
        downloadButton("descargar_serie_PNG", "PNG"),
        downloadButton("descargar_serie_CSV", "CSV")
        )
      ),
    fluidRow(
      box(
	width = 12,
        title = "Totales",
        color = "red",
        solidHeader = T,
        collapsible = T,
        plotOutput("graficar_total"),
        downloadButton("descargar_total_SVG", "SVG"),
        downloadButton("descargar_total_PNG", "PNG"),
        downloadButton("descargar_total_CSV", "CSV")
      )
    )
  )
)

print("Por definir servidor")
# Lógica para dibujar en la interfaz
servidor <- function(input, output, session) {

  datos <- reactive({
    subset(tablasub, SexoNac %in% input$sexonac &
        Categoria %in% input$categoria_rotulo &
        Departamento %in% input$departamento &
        Fecha >= input$rango[1] & Fecha <= input$rango[2])
  })

  serie <- reactive({
    plyr::count(datos(), c('Fecha', 'SexoNac', 'Departamento', 'Categoria'))
  })

  var_input <- reactive({ input$var })

  total <- reactive({
    plyr::count(serie(), c('SexoNac', 'Departamento', 'Categoria'))
  })

  graficar_serie <- reactive({
    if (input$var == 'SexoNac') {
      print("SexoNac")
      ggplot(data = serie(), aes(x = Fecha, y = freq, group = SexoNac, 
          colour=SexoNac)) +
      geom_line() + geom_point() +
      labs(title='Serie de tiempo por sexo de nacimiento',
        y='Victimizaciones', x= 'Fecha') +
      theme(legend.position="top", legend.title = element_blank())
    } else if (input$var == 'Departamento') {
      print("Departamento")
      ggplot(data = serie(), aes(x = Fecha, y = freq, group = Departamento, 
          colour=Departamento)) +
      geom_line() + geom_point() +
      labs(title='Serie de tiempo por departamento',
        y='Victimizaciones', x= 'Fecha') +
      theme(legend.position="top", legend.title = element_blank())
    } else if (input$var == 'Categoria') {
      print("Categoria")
      ggplot(data = serie(), aes(x = Fecha, y = freq, group = Categoria, 
          colour=Categoria)) +
      geom_line() + geom_point() +
      labs(title='Serie de tiempo por categoria',
        y='Victimizaciones', x= 'Fecha') +
      theme(legend.position="top", 
	    legend.title = element_blank()
      )
    }

  })

  graficar_total <- reactive({
    if (input$var == 'SexoNac') {
      ggplot(data = datos(), aes(x = SexoNac, fill = SexoNac))+
        geom_bar()+ ylab("Victimizaciones") +
        geom_text(stat = 'count', aes(label = ..count..), vjust = 1)
    } else if (input$var == 'Departamento') {
      ggplot(data = datos(), aes(x = Departamento, fill = Departamento))+
        geom_bar()+ ylab("Victimizaciones") +
        geom_text(stat = 'count', aes(label = ..count..), vjust = 1) +
	theme(
	    axis.text.x = element_blank(),
	    axis.ticks.x = element_blank()
	)
    } else if (input$var == 'Categoria') {
      ggplot(data = datos(), aes(x = Categoria, fill = Categoria))+
        geom_bar()+ ylab("Victimizaciones") +
        geom_text(stat = 'count', aes(label = ..count..), vjust = 1)+
	theme(
	    axis.text.x = element_blank(),
	    axis.ticks.x = element_blank()
	)
    } 

  })

  output$graficar_serie <- renderPlot({
    graficar_serie()
  })

  output$graficar_total <- renderPlot({
    graficar_total()
  })


  output$descargar_serie_SVG<- downloadHandler(
    filename = function() { paste("serie-sexonac", ".svg", sep = "") },
    content = function(nomarc){
      ggsave(nomarc, graficar_serie())
    }
  )

  output$descargar_serie_PNG<- downloadHandler(
    filename = function() {paste("serie-sexonac", ".png", sep = "")},
    content = function(nomarc){
      ggsave(nomarc, graficar_serie())
    }
  )

  output$descargar_serie_CSV<- downloadHandler(
    filename = function() {paste("serie-sexonac", ".csv", sep = "")},
    content = function(nomarc){
      print(nomarc)
      write.csv(serie(), nomarc)
    }
  )

  output$descargar_total_SVG <- downloadHandler(
    filename = function() {paste("total-sexonac", ".svg", sep = "")},
    content = function(nomarc){
      ggsave(nomarc, graficar_total())
    }
  )

  output$descargar_total_PNG <- downloadHandler(
    filename = function() {paste("total-sexonac", ".png", sep = "")},
    content = function(nomarc){
      ggsave(nomarc,graficar_total())
    }
  )

  output$descargar_total_CSV <- downloadHandler(
    filename = function() {paste("total-sexonac", ".csv", sep = "")},
    content = function(nomarc){
      print(nomarc)
      write.csv(total(), nomarc)
    }
  )

  output$vict_n <- renderValueBox({
    infoBox('Victimizaciones',
      paste0(nrow(datos())), 
      icon = icon('list-alt'),
      color = 'red')
  })
}

print("Por ejecutar shinyApp")
# La aplicación se ejecutaría así:
#shinyApp(ui = interfaz, server = servidor, 
#  options = list(host = "181.143.184.115", port = 2902))

