# Libreria
library(data.table)
library(tidyverse)

# Rutas 
auxiliar <- 'precios-textil/codigo/meli/auxiliar'
instub <- 'precios-textil/codigo/meli/input/base'
outstub <- instub

# Cargar datos 
data <- fread(file.path(instub,'base_unificada.csv'),
              encoding='UTF-8')

# Cargar tipo de cambio
tipo_cambio <- read_csv(file.path(auxiliar,'tipo_cambio.csv'))
tipo_cambio <- tipo_cambio %>% 
  mutate(Fecha_scrapeo = lubridate::ymd(Fecha_scrapeo))
tipo_cambio <- tipo_cambio %>% 
  group_by(pais,tipo_dato) %>% 
  filter(Fecha_scrapeo == max(Fecha_scrapeo)) %>% 
  select(-Fecha_scrapeo)
tipo_cambio_arg_celeste <- tipo_cambio %>% 
  filter(str_detect(pais,'Argentina')) %>% 
  mutate(pais = 'Argentina celeste') %>% 
  group_by(pais,tipo_dato) %>% 
  summarize(`Tipo de cambio`=mean(`Tipo de cambio`))
tipo_cambio <- union_all(tipo_cambio,tipo_cambio_arg_celeste)
tipo_cambio <- union_all(tipo_cambio,tipo_cambio %>% filter(tipo_dato == 'Sin filtro de tienda oficial') %>% mutate(tipo_dato='Solo tiendas no oficiales'))

# Armar argentina blue 
argenblue <- copy(data[pais == 'Argentina'])
argenblue <- argenblue[,pais := 'Argentina MEP']
argenceleste <- copy(argenblue)
argenceleste <- argenceleste[,pais := 'Argentina celeste']
data <- setDT(rbind(data,argenblue))
data <- setDT(rbind(data,argenceleste))
rm(argenblue)
rm(argenceleste)

# Armar datos "solo tiendas no oficiales" 
aux_oficiales <- data[tipo_dato == 'Filtrado tienda oficial']
aux_no_oficiales <- data[tipo_dato == 'Sin filtro de tienda oficial']
aux_no_oficiales <- aux_no_oficiales[! (id_producto %in% aux_oficiales$id_producto)]
aux_no_oficiales <- aux_no_oficiales[,tipo_dato := 'Solo tiendas no oficiales']

data <- setDT(rbind(data,aux_no_oficiales))

# Aplicar un factor de descuento a las cuotas sin interes para tener el precio "real" 
deflactor <- read_csv(file.path(auxiliar,'deflactor_cuotas.csv'))
deflactor <- deflactor %>% 
  mutate(`Factor de multiplicación del precio de venta` = if_else(`Factor de multiplicación del precio de venta` == 'Argentina blue','Argentina MEP',`Factor de multiplicación del precio de venta`))
# Pasar a long 
deflactor <- deflactor %>% 
  pivot_longer(-`Factor de multiplicación del precio de venta`,names_to='cuotas',values_to='deflactor')
deflactor <- deflactor %>% 
  rename(pais=`Factor de multiplicación del precio de venta`)
deflactor <- deflactor %>% 
  mutate(cuotas = as.double(str_extract(cuotas,'[0-9]+')))
deflactor <- deflactor %>% 
  rename(cuotas_sin_interes = cuotas)

# Armar cuotas de otros países 
data <- merge(data,deflactor,by=c('pais','cuotas_sin_interes'),all.x=T)
data <- data[,precio_venta := fifelse(!is.na(cuotas_sin_interes),precio_venta*deflactor,precio_venta)]
# Añadir TC 
data <- merge(data[,Fecha_scrapeo := lubridate::ymd(Fecha_scrapeo)],tipo_cambio,by=c('pais','tipo_dato'),all.x=T)
data <- data[,precio_dolares := fifelse(moneda_venta != 'U$S',precio_venta / `Tipo de cambio`,precio_venta)]

# Sacar packs (ej: venta de muchas medias en el mismo producto)
data <- data[,pack := fifelse(str_detect(str_to_lower(nombre),'pack|pacote|paquete|kit|unidades|x[0-9][0-9]|x[0-9]'),1,0)]
data <- data[pack == 0]
data$pack <- NULL

# Sacar los percentiles menores al 5 y mayores al 95 de cada producto 
data <- data[,cuantil := ntile(precio_dolares,100),by=c('pais','producto_buscado_arg')]
data <- data[cuantil > 5 & cuantil < 95]

# Boxer: para algunos paises tiene problemas porque hay otro tipo de productos. Ej: motos
# Se opta por retirar el producto de la base 
data <- data[producto_buscado_arg != 'Boxer hombre']

# Unificar los meses - Evita tener fechas distintas por pais. Lo relevante es el mes
data <- data[,mes := lubridate::ymd('2024-04-30')]

# Algunos productos en paises pequeños no corresponden a categorias de interes  
data <- data[!(pais == 'Peru' & str_detect(nombre,'Vectores'))]
data <- data[!(pais == 'Uruguay' & str_detect(str_to_lower(nombre),'champi|calzado|reloj|nike air max|air jordan'))]

# Guardar base 
fwrite(data,file.path(outstub,'base_final.csv'))
