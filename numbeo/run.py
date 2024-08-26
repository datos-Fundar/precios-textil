import argparse
import os
from scripts.scraper import get_numbeo_data
from scripts.processing import process_numbeo
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
    
    cat_prop = False
    cat_prop_str = ""

    if process_output:
        cat_prop = True
        cat_prop_str = "_cat_prop"

    numbeo_df = get_numbeo_data(cat_prop=cat_prop)

    today = datetime.today().strftime('%Y%m%d')
    if out_folder is None:
        print("No se especificó ninguna carpeta, default --> './exports/'")
        out_folder = "./exports"
        Path(out_folder).mkdir(parents=True, exist_ok=True)
      
    out_path = f"{out_folder}/scraping_numbeo{cat_prop_str}_{today}.csv"

    export_to_csv(df=numbeo_df, path=out_path)

    print(f"Scraping exportado a: {out_path}")

    if process_output:

        out_path_p = f"{out_folder}/precios_relativos_numbeo_{today}.xlsx"
        
        precios_relativos_df = process_numbeo(input_df=numbeo_df)
        
        export_to_xlsx(df=precios_relativos_df, path=out_path_p)
        print(f"Precios relativos exportado a: {out_path_p}")
