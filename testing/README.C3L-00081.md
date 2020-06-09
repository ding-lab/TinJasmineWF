# Past work

## Germline development with C3L-00001
Testing of germline CPTAC3 case C3L-00001 described here:
/gscuser/mwyczalk/projects/GermlineCaller/README.C3L-00001.md

Will test LSCC WXS normal case C3L-00081:
C3L-00081.WXS.N.hg38    C3L-00081   LSCC    WXS blood_normal    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/ec948c00-910b-4c7b-82a7-4d209d377116/5e04faec-58e8-403f-942b-74e8c0053805_gdc_realn.bam   39312702311 BAM hg38    ec948c00-910b-4c7b-82a7-4d209d377116    MGI

## TinDaisy Model Runs
Former TinDaisy runs: /gscuser/mwyczalk/projects/CromwellRunner/TinDaisy/8_CCRCC.HotspotProximity16.20200521/logs/stashed/074db967-d080-4ae5-a1e8-8e3f42e97412/C3N-00315.yaml


# Key configurations

## BAM and Reference
reference:  /gscmnt/gc7202/dinglab/common/Reference/A_Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
bam: /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/ec948c00-910b-4c7b-82a7-4d209d377116/5e04faec-58e8-403f-942b-74e8c0053805_gdc_realn.bam 


## CWL

Note that VEP annotate CWL has VEP arguments which are hardcoded and specific to TinJasmine, and different
from TinDaisy.  This may cause complications when this module is shared between the two workflows.

## ROI BED

From Fernanda:
/gscmnt/gc2737/ding/fernanda/Germline_MMY/FamilialMM/ReferenceFiles/BEDfiles/Homo_sapiens.GRCh38.95.allCDS.2bpFlanks.biomart.bed

## VEP v95

Will be installing VEP v95 cache to be compatible with Fernanda's workflow.
Describe how it was downloaded, make sure scripts available

For initial testing, will use VEP v99 which is already installed:

vep_cache_gz: /gscmnt/gc7202/dinglab/common/databases/VEP/v99/vep-cache.99_GRCh38.tar.gz
vep_cache_version: 99
assembly: GRCh38

## Config
These are in params distributed with VLD filter

varscan_filter_config:  /gscuser/mwyczalk/projects/GermlineCaller/TinJasmine/submodules/VLD_FilterVCF/params/VLD_FilterVCF-varscan.config.ini
pindel_filter_config:  /gscuser/mwyczalk/projects/GermlineCaller/TinJasmine/submodules/VLD_FilterVCF/params/VLD_FilterVCF-pindel.config.ini  
gatk_filter_config:  /gscuser/mwyczalk/projects/GermlineCaller/TinJasmine/submodules/VLD_FilterVCF/params/VLD_FilterVCF-GATK.config.ini


## Pindel Filter Config Template

This is distributed with Pindel Germline Caller params

pindel_config_template:  /Users/mwyczalk/Projects/GermlineCaller/TinJasmine/submodules/Pindel_GermlineCaller/params/pindel_germline_filter_config.ini

Contents:
```
pindel.filter.heterozyg_min_var_allele_freq = 0.2
pindel.filter.homozyg_min_var_allele_freq = 0.8
pindel.filter.mode = germline
pindel.filter.apply_filter = true
pindel.filter.germline.min_coverages = 10
pindel.filter.germline.min_var_allele_freq = 0.20
pindel.filter.germline.require_balanced_reads = true
pindel.filter.germline.remove_complex_indels = true
pindel.filter.germline.max_num_homopolymer_repeat_units = 6
```

TODO: confirm that these are consistent with what is done for Germline and/or TinDaisy


## Other

canonical_BED:  gscuser/mwyczalk/projects/TinDaisy/TinDaisy/params/chrlist/GRCh38.callRegions.bed

## Open questions

normal_barcode: 
  - and its cousin tumor_barcode.  Need to confirm that vcf2maf works right in the case of germline providing just one normal sample

reference:  # type "File"
    class: File
    path: a/file/path
bam:  # type "File"
    class: File
    path: a/file/path


