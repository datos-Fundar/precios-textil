# Tabla 2: mediana frente al promedio de Latam 

# Rutas 
instub <- 'precios-textil/meli/input/'
auxiliar <- 'precios-textil/meli/auxiliares'
outstub <- 'precios-textil/meli/output'

#Libreria
library(data.table)
library(tidyverse)
# Cargar datos 
data <- fread(file.path(instub,'base_final.csv'))

# Filtrar por productos de busquedas manuales 
data <- data[tipo_dato == 'Sin filtro de tienda oficial']

# Calculo de mediana por producto 
t1 <- data[,.(mediana_precio = median(precio_dolares_ajustado,na.rm=T)),
           by=c('producto_buscado_arg','pais','mes')]
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Cargar auxiliar con canasta 
aux <- read_csv(file.path(auxiliar,'canasta_engho_total.csv'))
aux <- aux %>% 
  mutate(producto_buscado_arg = str_to_lower(producto_buscado_arg),
         producto_buscado_arg = str_remove(producto_buscado_arg,'\\.$'),
         producto_buscado_arg = if_else(producto_buscado_arg == 'traje hombres','traje hombre',producto_buscado_arg),
         producto_buscado_arg = if_else(producto_buscado_arg == 'buzo bebé','buzo bebe',producto_buscado_arg))

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
t1$mes <- NULL

# Calcular el promedio america latina sin argentina
# Calculo de mediana por producto 
t2 <- data[,.(mediana_precio = median(precio_dolares_ajustado,na.rm=T)),
           by=c('producto_buscado_arg','pais','mes')]
t2 <- t2[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Filtrar productos  
t2 <- t2 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)
# Sacar Argentina 
t2 <- t2 %>% 
  filter(!str_detect(pais,'Argentina'))
t2$mes <- NULL

# Calcular el promedio simple por producto
t2 <- t2 %>% 
  group_by(producto_buscado_arg) %>% 
  summarize(promedio_latam = mean(mediana_precio))

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
multiplicar_100 <- function(x){x*100}
t1 <- t1 %>% 
  mutate_if(is.double,multiplicar_100)
# corregir nombres
t1 <- janitor::clean_names(t1)
# Agregar "precio" al nombre cuando corresponda
names(t1)[2:length(t1)] <- paste0('precio_indice_',names(t1)[2:length(t1)])
# Guardar bases 
write_csv(t1,file.path(outstub,'tabla 2 - mediana vs promedio latam.csv'))
