import argparse
import os
from scripts.scraper import countries, item2custom_category, get_expatistan_data
from scripts.processing import process_expatistan
from pathlib import Path
from datetime import datetime
import pandas as pd

def export_to_csv(df:pd.DataFrame, path:str)->None:
    df.to_csv(path, index=False)

def export_to_xlsx(df:pd.DataFrame, path:str)->None:
    df.to_excel(path, index=False)

class Parser(argparse.ArgumentParser):
    
    def __init__(self):
        super(Parser, self).__init__(description='Expatistan CLI')

        self.add_argument('-o', '--output_folder', type=str, help='Ruta de la carpeta en la que se exportará el archivo (default "./salidas/")')
        self.add_argument('-p','--process', type=bool, nargs='?', const=False, help='Si es True se agrega columna con `categoria propia` y además se genera procesamiento (default False)')
       
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
    process_output = args.get('process', False)

    if process_output:
        cat_prop_str = "_cat_prop"
        cat_prop = True
    
    expatistan_df = get_expatistan_data(country_list=countries.to_list(), cat_prop = cat_prop, mapper = item2custom_category)

    cat_prop_str = ""
    
    today = datetime.today().strftime('%Y%m%d')
    
    if out_folder is None:
        print("No se especificó ninguna carpeta, default --> './exports/'")
        out_folder = "./salidas"
        Path(out_folder).mkdir(parents=True, exist_ok=True)

    out_path = f"{out_folder}/scraping_expatistan{cat_prop_str}_{today}.csv"

    export_to_csv(df=expatistan_df, path=out_path)
    print(f"Scraping exportado a: {out_path}")

    if process_output:

        out_path_p = f"{out_folder}/precios_relativos_expatistan_{today}.xlsx"
        
        precios_relativos_df = process_expatistan(input_df=expatistan_df)
        
        export_to_xlsx(df=precios_relativos_df, path=out_path_p)
        print(f"Precios relativos exportado a: {out_path_p}")


