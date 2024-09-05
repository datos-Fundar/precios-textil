# Tabla 3: apertura de variables 

# Rutas 
instub <- 'precios-textil/meli/input/'
auxiliar <- 'precios-textil/meli/auxiliares'
outstub <- 'precios-textil/meli/output'

#Libreria
library(data.table)
library(tidyverse)

# Funciones ----
corregir_canasta <- function(x){
  x <-  x%>% 
    mutate(producto_buscado_arg = str_to_lower(producto_buscado_arg),
           producto_buscado_arg = str_remove(producto_buscado_arg,'\\.$'),
           producto_buscado_arg = if_else(producto_buscado_arg == 'traje hombres','traje hombre',producto_buscado_arg),
           producto_buscado_arg = if_else(producto_buscado_arg == 'buzo bebé','buzo bebe',producto_buscado_arg)) 
}
multiplicar_100 <- function(x){x*100}
# Cargar data 
data <- fread(file.path(instub,'base_final.csv'))
# Segun oferente ----
# Calculo de mediana por producto 
t1 <- data[,.(mediana_precio = median(precio_dolares,na.rm=T)),
           by=c('tipo_dato','producto_buscado_arg','pais','mes')]
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Cargar auxiliar con canasta 
aux <- read_csv(file.path(auxiliar,'canasta_engho_total.csv'))
aux <- corregir_canasta(aux)

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t1$mes <- NULL
# Joinear con canasta 
t1 <- t1 %>% 
  left_join(aux,by='producto_buscado_arg')
# Multiplicar producto por ponderacion 
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sumar productos de la canasta
t1 <- t1 %>% 
  group_by(tipo_dato,pais) %>% 
  summarize(mediana_precio = sum(mediana_precio))

# Calculo de mediana por producto 
t2 <- data[,.(mediana_precio = median(precio_dolares,na.rm=T)),
           by=c('tipo_dato','producto_buscado_arg','pais','mes')]
t2 <- t2[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Filtrar productos  
t2 <- t2 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
# Joinear con canasta 
t2 <- t2 %>% 
  left_join(aux,by='producto_buscado_arg')
# Multiplicar por canasta 
t2 <- t2 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sacar Argentina 
t2 <- t2 %>% 
  filter(!str_detect(pais,'Argentina'))
t2$mes <- NULL

# Calcular el promedio simple por producto y busqueda
t2 <- t2 %>% 
  group_by(tipo_dato,producto_buscado_arg) %>% 
  summarize(promedio_latam = mean(mediana_precio))
# Sumar valores 
t2 <- t2 %>% 
  group_by(tipo_dato) %>% 
  summarize(promedio_latam = sum(promedio_latam))
# Juntar bases 
t1 <- t1 %>% 
  left_join(t2)

# Calcular relacion 
t1 <- t1 %>% 
  mutate(indice = mediana_precio / promedio_latam)
t1$mediana_precio <- NULL
t1$promedio_latam <- NULL
# Pivotear
t1 <- t1 %>% 
  pivot_wider(names_from=pais,values_from=indice)
# Multiplicar por 100
t1 <- t1 %>% 
  mutate_if(is.double,multiplicar_100)

tabla_tiendas <- t1 %>% 
  mutate(variable = 'Oferente') %>% 
  rename(apertura=tipo_dato) 
tabla_tiendas <- tabla_tiendas %>% 
  relocate(variable)

# Segun gama ----
# Calculo de mediana por producto 
t1 <- copy(data)
t1 <- t1[,percentil := fcase(cuantil >= 90,'Alta gama',
                             cuantil <= 10,'Baja gama')]
t1 <- t1[!is.na(percentil)]
t1 <- t1[,.(mediana_precio = median(precio_dolares,na.rm=T)),
         by=c('percentil','producto_buscado_arg','pais','mes')]
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Cargar auxiliar con canasta 
aux <- read_csv(file.path(auxiliar,'canasta_engho_total.csv'))
aux <- corregir_canasta(aux)

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t1$mes <- NULL
# Joinear con canasta 
t1 <- t1 %>% 
  left_join(aux,by='producto_buscado_arg')
# Multiplicar producto por ponderacion 
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sumar productos de la canasta
t1 <- t1 %>% 
  group_by(percentil,pais) %>% 
  summarize(mediana_precio = sum(mediana_precio))

# Calculo de mediana por producto 
t2 <- copy(data)
t2 <- t2[,percentil := fcase(cuantil >= 90,'Alta gama',
                             cuantil <= 10,'Baja gama')]
t2 <- t2[!is.na(percentil)]
t2 <- t2[,.(mediana_precio = median(precio_dolares,na.rm=T)),
           by=c('percentil','producto_buscado_arg','pais','mes')]
t2 <- t2[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Filtrar productos  
t2 <- t2 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
# Joinear con canasta 
t2 <- t2 %>% 
  left_join(aux,by='producto_buscado_arg')
# Multiplicar por canasta 
t2 <- t2 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sacar Argentina 
t2 <- t2 %>% 
  filter(!str_detect(pais,'Argentina'))
t2$mes <- NULL

# Calcular el promedio simple por producto y busqueda
t2 <- t2 %>% 
  group_by(percentil,producto_buscado_arg) %>% 
  summarize(promedio_latam = mean(mediana_precio))
# Sumar valores 
t2 <- t2 %>% 
  group_by(percentil) %>% 
  summarize(promedio_latam = sum(promedio_latam))
# Juntar bases 
t1 <- t1 %>% 
  left_join(t2)

# Calcular relacion 
t1 <- t1 %>% 
  mutate(indice = mediana_precio / promedio_latam)
t1$mediana_precio <- NULL
t1$promedio_latam <- NULL
# Pivotear
t1 <- t1 %>% 
  pivot_wider(names_from=pais,values_from=indice)
# Multiplicar por 100
t1 <- t1 %>% 
  mutate_if(is.double,multiplicar_100)

tabla_gama <- t1 %>% 
  mutate(variable = 'Gama') %>% 
  rename(apertura=percentil) 
tabla_gama <- tabla_gama %>% 
  relocate(variable)

# Segun destinatario ----
# Calculo de mediana por producto 
t1 <- copy(data)
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]
# Cargar auxiliares 
aux1 <- fread(file.path(auxiliar,'canasta_engho_hombre.csv'))
aux1 <- aux1[,destinatario := 'hombre']
aux2 <- fread(file.path(auxiliar,'canasta_engho_mujer.csv'))
aux2 <- aux2[,destinatario := 'mujer']
aux3 <- fread(file.path(auxiliar,'canasta_engho_niño.csv'))
aux3 <- aux3[,destinatario := 'bebés y niños']
aux <- setDT(bind_rows(aux1,aux2))
aux <- setDT(bind_rows(aux,aux3))

aux <- corregir_canasta(aux)

# Añadir destinatario 
t1 <- merge(t1,aux,by='producto_buscado_arg',all.x=T)
t1 <- t1[!is.na(share_canasta)]

# Calcular mediana 
t1 <- t1[,.(mediana_precio = median(precio_dolares,na.rm=T)),
         by=c('destinatario','producto_buscado_arg','pais','mes')]

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t1$mes <- NULL
# Joinear con canasta 
t1 <- t1 %>% 
  left_join(aux,by=c('producto_buscado_arg','destinatario'))
# Multiplicar producto por ponderacion 
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sumar productos de la canasta
t1 <- t1 %>% 
  group_by(destinatario,pais) %>% 
  summarize(mediana_precio = sum(mediana_precio))

# IDEM PARA LATAM SIN ARG 

# Calculo de mediana por producto 
t2 <- copy(data)
t2 <- t2[!str_detect(pais,'Argentina')]
t2 <- t2[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]
# Cargar auxiliares 
aux1 <- fread(file.path(auxiliar,'canasta_engho_hombre.csv'))
aux1 <- aux1[,destinatario := 'hombre']
aux2 <- fread(file.path(auxiliar,'canasta_engho_mujer.csv'))
aux2 <- aux2[,destinatario := 'mujer']
aux3 <- fread(file.path(auxiliar,'canasta_engho_niño.csv'))
aux3 <- aux3[,destinatario := 'bebés y niños']
aux <- setDT(bind_rows(aux1,aux2))
aux <- setDT(bind_rows(aux,aux3))

aux <- corregir_canasta(aux)

# Añadir destinatario 
t2 <- merge(t2,aux,by='producto_buscado_arg',all.x=T)
t2 <- t2[!is.na(share_canasta)]

# Calcular mediana 
t2 <- t2[,.(mediana_precio = median(precio_dolares,na.rm=T)),
         by=c('destinatario','producto_buscado_arg','pais','mes')]

# Filtrar productos de la canasta 
t2 <- t2 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t2$mes <- NULL
# Joinear con canasta 
t2 <- t2 %>% 
  left_join(aux,by=c('producto_buscado_arg','destinatario'))
# Multiplicar producto por ponderacion 
t2 <- t2 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)

# Calcular el promedio simple por producto y busqueda
t2 <- t2 %>% 
  group_by(destinatario,producto_buscado_arg) %>% 
  summarize(promedio_latam = mean(mediana_precio))
# Sumar valores 
t2 <- t2 %>% 
  group_by(destinatario) %>% 
  summarize(promedio_latam = sum(promedio_latam))

# Juntar bases 
t1 <- t1 %>% 
  left_join(t2)

# Calcular relacion 
t1 <- t1 %>% 
  mutate(indice = mediana_precio / promedio_latam)
t1$mediana_precio <- NULL
t1$promedio_latam <- NULL
# Pivotear
t1 <- t1 %>% 
  pivot_wider(names_from=pais,values_from=indice)
# Multiplicar por 100
t1 <- t1 %>% 
  mutate_if(is.double,multiplicar_100)

tabla_destinatario <- t1 %>% 
  mutate(variable = 'Destinatario') %>% 
  rename(apertura=destinatario) 
tabla_destinatario <- tabla_destinatario %>% 
  relocate(variable)

# Segun material y confeccion ----
# Calculo de mediana por producto 
t1 <- copy(data)
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]
# Cargar auxiliares 
aux1 <- corregir_canasta(fread(file.path(auxiliar,'tipo_prenda.csv')))
aux2 <- corregir_canasta(fread(file.path(auxiliar,'canasta_engho_total.csv')))
aux <- merge(aux1,aux2,by='producto_buscado_arg',all.x=T)

# Añadir destinatario 
t1 <- merge(t1,aux,by='producto_buscado_arg',all.x=T)
t1 <- t1[!is.na(share_canasta)]

# Calcular mediana 
t1 <- t1[,.(mediana_precio = median(precio_dolares,na.rm=T)),
         by=c('tipo_prenda','producto_buscado_arg','pais','mes')]

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t1$mes <- NULL
# Joinear con canasta 
t1 <- t1 %>% 
  left_join(aux,by=c('producto_buscado_arg','tipo_prenda'))
# Multiplicar producto por ponderacion 
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)
# Sumar productos de la canasta
t1 <- t1 %>% 
  group_by(tipo_prenda,pais) %>% 
  summarize(mediana_precio = sum(mediana_precio))

# IDEM PARA LATAM SIN ARG 

t2 <- copy(data)
t2 <- t2[!str_detect(pais,'Argentina')]
t2 <- t2[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]
# Cargar auxiliares 
aux1 <- corregir_canasta(fread(file.path(auxiliar,'tipo_prenda.csv')))
aux2 <- corregir_canasta(fread(file.path(auxiliar,'canasta_engho_total.csv')))
aux <- merge(aux1,aux2,by='producto_buscado_arg',all.x=T)

# Añadir destinatario 
t2 <- merge(t2,aux,by='producto_buscado_arg',all.x=T)
t2 <- t2[!is.na(share_canasta)]

# Calcular mediana 
t2 <- t2[,.(mediana_precio = median(precio_dolares,na.rm=T)),
         by=c('tipo_prenda','producto_buscado_arg','pais','mes')]

# Filtrar productos de la canasta 
t2 <- t2 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t2$mes <- NULL

# Joinear con canasta 
t2 <- t2 %>% 
  left_join(aux,by=c('producto_buscado_arg','tipo_prenda'))
# Multiplicar producto por ponderacion 
t2 <- t2 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)

# Calcular el promedio simple por producto y busqueda
t2 <- t2 %>% 
  group_by(tipo_prenda,producto_buscado_arg) %>% 
  summarize(promedio_latam = mean(mediana_precio))
# Sumar valores 
t2 <- t2 %>% 
  group_by(tipo_prenda) %>% 
  summarize(promedio_latam = sum(promedio_latam))

# Juntar bases 
t1 <- t1 %>% 
  left_join(t2)

# Calcular relacion 
t1 <- t1 %>% 
  mutate(indice = mediana_precio / promedio_latam)
t1$mediana_precio <- NULL
t1$promedio_latam <- NULL
# Pivotear
t1 <- t1 %>% 
  pivot_wider(names_from=pais,values_from=indice)
# Multiplicar por 100
t1 <- t1 %>% 
  mutate_if(is.double,multiplicar_100)

tabla_material <- t1 %>% 
  mutate(variable = 'Material y confección') %>% 
  rename(apertura=tipo_prenda) 
tabla_material <- tabla_material %>% 
  relocate(variable)

# Unificar bases ----
tabla_final <- tibble()
tabla_final <- bind_rows(tabla_final,tabla_tiendas)
tabla_final <- bind_rows(tabla_final,tabla_gama)
tabla_final <- bind_rows(tabla_final,tabla_destinatario)
tabla_final <- bind_rows(tabla_final,tabla_material)

# Arreglar nombres 
tabla_final <- janitor::clean_names(tabla_final)
# Agregar "precio" al nombre cuando corresponda
names(tabla_final)[3:length(tabla_final)] <- paste0('precio_indice_',names(tabla_final)[3:length(tabla_final)])
# Guardar bases 
write_csv(tabla_final,file.path(outstub,'tabla 3 - mediana vs promedio latam por categoria.csv'))