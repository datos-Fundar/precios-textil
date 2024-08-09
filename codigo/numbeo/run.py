import argparse
import os
import scraper
from pathlib import Path
from datetime import datetime

class Parser(argparse.ArgumentParser):
    
    def __init__(self):
        super(Parser, self).__init__(description='Expatistan CLI')

        self.add_argument('-o', '--output_folder', type=str, help='Ruta de la carpeta en la que se exportará el archivo (default "./exports/")')
        # self.add_argument('-c','--cat_prop', type=bool, nargs='?', const=False, help='Si es True se agrega columna con `categoria propia` (default False)')
       
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
    # cat_prop = args.get('cat_prop', False)
    
    df = scraper.get_numbeo_data()

    cat_prop_str = ""
    
    today = datetime.today().strftime('%Y%m%d')
    if out_folder is None:
        print("No se especificó ninguna carpeta, default --> './exports/'")
        out_folder = "./exports"
        Path(out_folder).mkdir(parents=True, exist_ok=True)

    # if cat_prop:
    #     cat_prop_str = "_cat_prop" 
    
    out_path = f"{out_folder}/numbeo{cat_prop_str}_{today}.csv"

    scraper.export_to_csv(df=df, path=out_path)