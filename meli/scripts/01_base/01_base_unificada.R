# Textil scraper: Unificar datos y criterios de los países 

# Librerias
library(data.table)
library(tidyverse)
library(googledrive)

# Rutas 
instub <- 'precios-textil/meli/input/raw/'
outstub <- 'precios-textil/meli/input/base/'

#Archivos en ruta
files <- list.files(file.path(instub),pattern='*.rds',full.names=T)

# Bases crudas 
files <- files[str_detect(files,'scraper_manual')]
files <- as_tibble(files)
files <- files %>% 
  rename(name = value)
files <- files %>% 
  mutate(fecha = lubridate::ymd(str_extract(name,'[0-9]+-[0-9]+-[0-9]+')),
         version = if_else(str_detect(name,'tiendas_oficiales'),'V3','V2'),
         pais = str_extract(str_remove(name,instub),'^[0-9]+_[a-z]+'),
         pais = str_remove(pais,'^[0-9]+_'),
         pais = str_to_title(pais))
files <- files %>% 
  group_by(pais,version) %>% 
  filter(fecha == max(fecha))
files <- files %>% 
  ungroup()

# Creacion de funciones
correccion_arg <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+ cuotas'),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+'),
           cuotas_sin_interes = as.double(cuotas_sin_interes),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}
correccion_col <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+ cuotas'),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+'),
           cuotas_sin_interes = as.double(cuotas_sin_interes),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}
correccion_bra <- function(x){
  x <- x %>% 
    #filter(!str_count(precio_venta,'\\.') > 1) %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = str_extract(cuotas,'em[0-9]+x'),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+'),
           cuotas_sin_interes = as.double(cuotas_sin_interes),
           
           cuotas_con_interes = str_extract(cuotas_normales,'em[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('em',cuotas_con_interes,'x R\\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)
    ) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}

correccion_uy <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+ cuotas'),
           cuotas_sin_interes = str_extract(cuotas,'[0-9]+'),
           cuotas_sin_interes = as.double(cuotas_sin_interes),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)
    ) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}

correccion_chi <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = as.double(str_extract(str_extract(cuotas,'[0-9]+x'),'[0-9]+')),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)
    ) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}

correccion_per <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\.')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\.')),
           cuotas_sin_interes = as.double(str_extract(str_extract(cuotas,'[0-9]+x'),'[0-9]+')),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)
    ) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}
correccion_mex <- function(x){
  x <- x %>% 
    mutate(precio_venta = as.double(str_remove_all(precio_venta,'\\,')),
           precio_lista = as.double(str_remove_all(precio_lista,'\\,')),
           cuotas_sin_interes = as.double(str_extract(str_extract(cuotas,'en[0-9]+ meses'),'[0-9]+')),
           
           cuotas_con_interes = str_extract(cuotas_normales,'en[0-9]+x '),
           cuotas_con_interes = str_extract(cuotas_con_interes,'[0-9]+'),
           cuotas_con_interes = as.double(cuotas_con_interes),
           
           precio_cuotas_con_interes = str_remove(cuotas_normales,paste0('en',cuotas_con_interes,'x \\$')),
           
           precio_cuotas = precio_venta / cuotas_sin_interes,
           descuento_calculo = 1-(precio_venta / precio_lista)
    ) %>% 
    mutate(nombre = str_squish(nombre),
           nombre = str_trim(nombre),
           Categoria = str_extract(nombre,'(.*?) '))
  x <- x %>% 
    select(pais,Fecha_scrapeo,producto_buscado,nombre,precio_venta,precio_lista,moneda_venta,cuotas_sin_interes,cuotas_con_interes,precio_cuotas,precio_cuotas_con_interes,descuento_calculo,url_producto,envio,highlight,todo,producto_buscado_arg,categoria,tienda_of)
}

data_final <- data.table()
i <- 1
for(i in 1:length(files$name)){
  tmp <- files %>% filter(row_number() == i) 
  # Fecha scrapeo 
  fecha <- tmp$fecha
  fecha <- lubridate::ymd(fecha)
  # Pais 
  pais <- tmp$pais
  # Tipo de busqueda
  tipo_dato <- tmp$version
  tipo_dato <- if_else(tipo_dato == 'V2','Sin filtro de tienda oficial','Filtrado tienda oficial')
  if(pais == 'Perú'){
    pais <- 'Peru'
  }
  # Agregar pais y fecha de scrapeo 
  tmp <- readRDS(file.path(tmp$name))
  setDT(tmp)
  # Filtrar publicidades
  tmp <- tmp[!str_detect(url_producto,'https:\\/\\/click1')]
  # Añadir fecha de scrapeo
  tmp <- tmp[,Fecha_scrapeo := fecha]
  if(!pais %in% colnames(tmp)){
    tmp <- tmp[,pais := pais]
  }
  if(pais == 'Peru'){
    tmp <- tmp[,pais := 'Peru']
  }
  # Agregar si no esta la columna Todo 
  if(! 'todo' %in% colnames(tmp)){
    tmp <- tmp[,todo := '']
  }
  # Agregar si no esta la columna tienda_of 
  if(! 'tienda_of' %in% colnames(tmp)){
    tmp <- tmp[,tienda_of := '']
  }
  pais <- unique(tmp$pais)
  # Corregir precios y homegeneizar 
  if(pais == 'Argentina'){
    tmp <- correccion_arg(tmp)
    warnings()
  } else if(pais == 'Brasil') {
    tmp <- correccion_bra(tmp)
    warnings()
  } else if(pais == 'Chile') {
    tmp <- correccion_chi(tmp)
    warnings()
  } else if(pais == 'Peru') {
    tmp <- correccion_per(tmp)
    warnings()
  } else if(pais == 'Uruguay') {
    tmp <- correccion_uy(tmp)
    warnings()
  } else if(pais == 'Colombia'){
    tmp <- correccion_col(tmp)
    warnings()
  } else if(pais == 'Mexico'){
    tmp <- correccion_mex(tmp)
    warnings()
  }
  tmp <- tmp[,tipo_dato := tipo_dato]
  data_final <- plyr::rbind.fill(data_final,tmp)
  print(i)
}

# Arreglar mes 
data_final <- data_final %>% 
  mutate(mes = str_extract(Fecha_scrapeo,'[0-9]+-[0-9]+'))

# ID de producto 
data_final <- data_final %>% 
  mutate(id_producto = str_extract(url_producto,'ML[A-Z]\\-[0-9]+|ML[A-Z][0-9]+|MPE\\-[0-9]+|MPE[0-9]+|MCO\\-[0-9]+|MCO[0-9]+'))

# Quedarme con el ultimo mes 
setDT(data_final)
data_final <- data_final[,mes := paste0(mes,'-01')]
data_final <- data_final[,mes := lubridate::ymd(mes)]

meses <- data_final[,.(mes_max = max(mes)),by='pais']
data_final <- data_final[mes %in% meses$mes_max]


# Cambiar los meses por los seleccionados 
data_final <- data_final[,mes := fcase(pais == 'Argentina','2024-04-21',
                                       pais == 'Brasil','2024-04-30',
                                       pais == 'Chile','2024-04-26',
                                       pais == 'Colombia','2024-04-30',
                                       pais == 'Mexico','2024-04-28',
                                       pais == 'Peru','2024-04-28',
                                       pais == 'Uruguay','2024-04-30')]

data <- copy(data_final)
rm(list=setdiff(ls(),'data'))