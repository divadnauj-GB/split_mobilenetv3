import argparse
import pandas as pd
import os
import sys

def main(args):
    pd.set_option('mode.use_inf_as_na', True)   
    if args.path:
        items = os.listdir(args.path)
        csvfiles = [item for item in items if "F_" in item]  
        if len(csvfiles)>0:
            if (os.path.exists(os.path.join(args.path,"Misclassified_images_report.csv"))):
                for rep_per_fault in csvfiles:
                    os.remove(os.path.join(args.path,rep_per_fault))
            else:
                full_report = pd.DataFrame()
                for rep_per_fault in csvfiles:
                    fault_list= pd.read_csv(os.path.join(args.path,rep_per_fault),index_col=[0]) 
                    full_report=pd.concat([full_report,fault_list],axis=0, ignore_index=True, sort=False)                
                full_report.to_csv(os.path.join(args.path,"Misclassified_images_report.csv"))   

                for rep_per_fault in csvfiles:
                    os.remove(os.path.join(args.path,rep_per_fault))         
        
        fault_list_file=os.path.join(args.path,"fault_list.csv")
        fsim_report_file=os.path.join(args.path,"fsim_report.csv")
        fault_list= pd.read_csv(fault_list_file,index_col=[0]) 
        fsim_report= pd.read_csv(fsim_report_file,index_col=[0]) 

        index=((fsim_report['gold_ACC@1'].isna()==False) | (fsim_report['gold_ACC@k'].isna()==False))
        fsim_report=fsim_report.loc[index]
        full_reportfs=pd.concat([fault_list,fsim_report],axis=1)
        full_reportfs.to_csv(os.path.join(args.path,"fsim_full_report.csv"))

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='pytorchFI report merge')
    parser.add_argument('-p', '--path', metavar='DIR',
                        help='path to dataset')
    main(parser.parse_args())