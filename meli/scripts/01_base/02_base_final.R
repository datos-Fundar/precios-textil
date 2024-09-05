# Libreria
library(data.table)
library(tidyverse)

# Correr codigo que unifica las bases crudas y genera la base de trabajo
source(r'(precios-textil\meli\scripts\01_base\01_base_unificada.R)')

# Rutas 
auxiliar <- 'precios-textil/meli/auxiliares'
instub <- 'precios-textil/meli/input/'
outstub <- instub

# Armar argentina blue 
argenblue <- copy(data[pais == 'Argentina'])
argenblue <- argenblue[,pais := 'Argentina MEP']
data <- setDT(rbind(data,argenblue))
rm(argenblue)

# Marcar las filas que corresponden a tiendas oficiales 
data <- data[,oficial := fifelse(tipo_dato == 'Filtrado tienda oficial',1,0)]
data <- data[,no_oficial := fifelse(tipo_dato == 'Sin filtro de tienda oficial',1,0)]

# Ver productos repetidos 
data <- data[,cantidad_repetidos := .N,by=c('pais','id_producto')]
data <- data[,id_unico := 1:.N,by=c('pais','id_producto')]
data <- data[,tiene_oficial := max(oficial,na.rm=T),by=c('pais','id_producto')]

# Cambiar tipo de producto
data <- data[,cambiar := fifelse(tipo_dato=="Sin filtro de tienda oficial" & tiene_oficial==1,1,0)]
data <- data[,tipo_dato2 := fcase(no_oficial == 1 & cambiar == 0,'Solo tiendas no oficiales',
                                  oficial == 1,'Tiendas oficiales',
                                  no_oficial == 1 & cambiar == 1,'')]
data <- data[,tipo_dato2 := fifelse(is.na(tipo_dato2),tipo_dato,tipo_dato2)]

# # Armar datos "solo tiendas no oficiales" 
# aux_oficiales <- data[tipo_dato == 'Filtrado tienda oficial']
# aux_no_oficiales <- data[tipo_dato == 'Sin filtro de tienda oficial']
# aux_no_oficiales <- aux_no_oficiales[! (id_producto %in% aux_oficiales$id_producto)]
# aux_no_oficiales <- aux_no_oficiales[,tipo_dato := 'Solo tiendas no oficiales']
# 
# data <- setDT(rbind(data,aux_no_oficiales))

# Detectar de productos duplicados 
data <- data[,productos_final := 1]
data <- data[,productos_final := fifelse(id_unico > 2,0,1)]

# Detectar packs (ej: venta de muchas medias en el mismo producto)
data <- data[,pack := fifelse(str_detect(str_to_lower(nombre),'pack|pacote|paquete|kit|unidades|x[0-9][0-9]|x[0-9]'),1,0)]
data <- data[,productos_final := fifelse(pack == 1,0,productos_final)]

# Boxer: para algunos paises tiene problemas porque hay otro tipo de productos. Ej: motos
# Se opta por retirar el producto de la base 
data <- data[,productos_final := fifelse(producto_buscado_arg == 'Boxer hombre',0,productos_final)]

# Algunos productos no corresponden a categorias de interes  
data <- data[,productos_final := fifelse(pais == 'Peru' & str_detect(str_to_lower(nombre),'vectores'),0,productos_final)]
data <- data[,productos_final := fifelse(pais == 'Uruguay' & str_detect(str_to_lower(nombre),'champi|calzado|reloj|nike air max|air jordan'),0,productos_final)]
data <- data[,productos_final := fifelse(pais == 'Chile' & producto_buscado_arg == 'Soquetes' & str_detect(str_to_lower(nombre),'cama|colch|bot'),0,productos_final)]

# Modificar categorias incorrectas en Brasil
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa femenina" & producto_buscado_arg=="buzo bebe" & str_detect(str_to_lower(nombre), "manga curta"),'Blusa mujer',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa femenina" & producto_buscado_arg=="buzo bebe" & str_detect(str_to_lower(nombre), "shirt"),'Remera mujer',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa femenina" & producto_buscado_arg=="buzo bebe" & str_detect(str_to_lower(nombre), "camiset"),'Blusa mujer',producto_buscado_arg)]

data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa bebe" & producto_buscado_arg=="buzo mujer" & str_detect(str_to_lower(nombre), "manga curta"),'Remera bebés',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa bebe" & producto_buscado_arg=="buzo mujer" & str_detect(str_to_lower(nombre), "shirt"),'Remera bebés',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa bebe" & producto_buscado_arg=="buzo mujer" & str_detect(str_to_lower(nombre), "camiset"),'Remera bebés',producto_buscado_arg)]

data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa infantil" & producto_buscado_arg=="buzo niño" & str_detect(str_to_lower(nombre), "manga curta"),'Remera niños',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa infantil" & producto_buscado_arg=="buzo niño" & str_detect(str_to_lower(nombre), "shirt"),'Remera niños',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa infantil" & producto_buscado_arg=="buzo niño" & str_detect(str_to_lower(nombre), "camiset"),'Remera niños',producto_buscado_arg)]

data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa masculino" & producto_buscado_arg=="buzo hombre" & str_detect(str_to_lower(nombre), "manga curta"),'Remera hombre',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa masculino" & producto_buscado_arg=="buzo hombre" & str_detect(str_to_lower(nombre), "shirt"),'Remera hombre',producto_buscado_arg)]
data <- data[,producto_buscado_arg := fifelse(pais=="Brasil" & producto_buscado=="Blusa masculino" & producto_buscado_arg=="buzo hombre" & str_detect(str_to_lower(nombre), "camiset"),'Remera hombre',producto_buscado_arg)]

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

# Añadir TC 
data <- merge(data[,Fecha_scrapeo := lubridate::ymd(Fecha_scrapeo)],tipo_cambio,by=c('pais','tipo_dato'),all.x=T)
data <- data[,precio_dolares := fifelse(moneda_venta != 'U$S',precio_venta / `Tipo de cambio`,precio_venta)]

# Detectar los percentiles menores al 6 y mayores al 95 de cada producto 
data <- data[,cuantil := ntile(precio_venta,100),by=c('pais','producto_buscado_arg')]
data <- data[,productos_final := fifelse(cuantil < 6 | cuantil > 95,0,productos_final)]

# Armar cuotas de otros países 
data <- merge(data,deflactor,by=c('pais','cuotas_sin_interes'),all.x=T)
data <- data[,precio_dolares_ajustado := fifelse(!is.na(cuotas_sin_interes),precio_dolares*deflactor,precio_dolares)]

# Eliminar productos que no interesan 
data <- data[productos_final == 1]

# Unificar los meses - Evita tener fechas distintas por pais. Lo relevante es el mes
data <- data[,mes := lubridate::ymd('2024-04-30')]

# Emprolijar nombres 
data <- janitor::clean_names(data)

# Eliminar variables que no se utilizan 
data$precio_cuotas <- NULL
data$precio_cuotas_con_interes <- NULL
data$pack <- NULL
data$cambiar <- NULL
data$tipo_dato2 <- NULL
data$productos_final <- NULL
data$tiene_oficial <- NULL
data$no_oficial <- NULL
data$cantidad_repetidos <- NULL
data$id_unico <- NULL
# Renombrar variable 
setnames(data,'todo','texto_completo')

# Guardar base # GuardNULLar base 
fwrite(data,file.path(outstub,'base_final.csv'))
