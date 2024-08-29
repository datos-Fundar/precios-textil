import argparse
import os
from scripts.scraper import get_expatistan_data, expatistan_countries
from scripts.processing import process_expatistan
from scripts.table_result import get_table_result
from pathlib import Path
from datetime import datetime
import pandas as pd

def export_to_csv(df:pd.DataFrame, path:str)->None:
    df.to_csv(path, index=False)

def export_to_xlsx(df:pd.DataFrame, path:str)->None:
    df.to_excel(path, index=False)

def str_to_bool(value):
    if isinstance(value, bool):
        return value
    if value.lower() in {'true', 't', 'yes', 'y', '1'}:
        return True
    elif value.lower() in {'false', 'f', 'no', 'n', '0'}:
        return False
    else:
        raise argparse.ArgumentTypeError('Se espera un booleano (True/False).')
    
def is_valid_country(value):
    if value in expatistan_countries:
        return value
    else:
        raise argparse.ArgumentTypeError('Se expera un país válido de Expatistan')
    
class Parser(argparse.ArgumentParser):
    
    def __init__(self):
        super(Parser, self).__init__(description='Expatistan CLI')

        self.add_argument('-o', '--output_folder', 
                          type=str, 
                          help='Ruta de la carpeta en la que se exportará el archivo (default "./salidas/")'
                          )
        
        self.add_argument('-c','--cat_prop', 
                          type=str_to_bool, 
                          choices=[True, False],
                          default=False,
                          help='Indica si se debe el archivo debe ser exportado con la categoria propia de agrupamiento de items (True/False, default "False").'
                        )
        
        self.add_argument('-p','--process', 
                          type=str_to_bool, 
                          choices=[True, False],
                          default=False,
                          help='Indica si se debe procesar el archivo (True/False, default "False")'
                        )
        
        self.add_argument('-r','--table_result', 
                          type=is_valid_country, 
                          choices=expatistan_countries,
                          help='Indica el país que debería tomarse para generar la tabla de resultados'
                        )
         
            
        # Argumento de debug para poder testear los argumentos.
        # Si está, no se ejecuta el programa.
        self.add_argument('--testarguments', '--testarguments', type=bool, help=argparse.SUPPRESS)
    
    def get_args(self): ...

    def parse_args(self):
        self.args = super(Parser, self).parse_args().__dict__
        return self
    

if __name__ == '__main__':
    parser = Parser().parse_args()
    args = parser.args

    if all(map(lambda x: x is None, args.values())):
        print('No se especificó ningún argumento')
        parser.print_help()
        exit(1)

    out_folder = args.get('out_folder', None)
    process_output = args.get('process')
    cat_prop = args.get('cat_prop')
    result_pais = args.get('table_result')
    
    cat_prop_str = ""

    if result_pais: 
        process_output = True

    if process_output:
        cat_prop = True

    if cat_prop:
        print("Se agregará el agrupamiento de items en la variable 'categoria_propia' en el dataset exportado")
        cat_prop_str = "_cat_prop"
    
    expatistan_df = get_expatistan_data(cat_prop = cat_prop)

    cat_prop_str = ""
    
    today = datetime.today().strftime('%Y%m%d')
    
    if out_folder is None:
        print("No se especificó ninguna carpeta, default --> './salidas/'")
        out_folder = "./salidas"
        Path(out_folder).mkdir(parents=True, exist_ok=True)

    out_path = f"{out_folder}/datos_expatistan{cat_prop_str}_{today}.csv"

    export_to_csv(df=expatistan_df, path=out_path)
    print(f"Scraping exportado a: {out_path}")

    if process_output:

        out_path_p = f"{out_folder}/precios_relativos_expatistan_{today}.csv"
        
        precios_relativos_df = process_expatistan(input_df=expatistan_df)
        
        export_to_csv(df=precios_relativos_df, path=out_path_p)
        print(f"Precios relativos exportado a: {out_path_p}")


    if result_pais:

        out_path_r = f"{out_folder}/tabla_resultados_expatistan_{today}.csv"

        result_df = get_table_result(input_df=precios_relativos_df, pais=result_pais)
        
        export_to_csv(df=result_df, path=out_path_r)
        print(f"Precios relativos exportado a: {out_path_r}")


