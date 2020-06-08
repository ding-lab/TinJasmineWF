class: Workflow
cwlVersion: v1.0
id: tin_jasmine
label: TinJasmine
inputs:
  - id: bam
    type: File
  - id: reference
    type: File
  - id: gatk_snp_filter_config
    type: File
  - id: gatk_indel_filter_config
    type: File
  - id: pindel_config_template
    type: File
  - id: pindel_filter_config
    type: File
  - id: varscan_indel_filter_config
    type: File
  - id: varscan_snp_filter_config
    type: File
  - id: ROI_BED
    type: File
  - id: vep_cache_gz
    type: File?
  - id: vep_cache_version
    type: string?
  - id: assembly
    type: string?
  - id: Canonical_BED
    type: File
  - id: tumor_barcode
    type: string?
outputs:
  - id: clean_VCF
    outputSource:
      canonical_filter/output
    type: File
  - id: allCall_VCF
    outputSource:
      vep_annotate/output_dat
    type: File
  - id: clean_MAF
    outputSource:
      vcf2maf/output
    type: File
steps:
  - id: gatk_germline_caller
    in:
      - id: reference
        source: reference
      - id: bam
        source: bam
    out:
      - id: snp_vcf
      - id: indel_vcf
    run: ../../GATK_GermlineCaller/cwl/GATK_GermlineCaller.cwl
    label: GATK_GermlineCaller
  - id: pindel_germline_caller
    in:
      - id: reference
        source: reference
      - id: bam
        source: bam
    out:
      - id: pindel_sifted
    run: ../../Pindel_GermlineCaller/cwl/pindel_caller.Pindel_GermlineCaller.cwl
    label: Pindel_GermlineCaller
  - id: pindel_filter
    in:
      - id: pindel_sifted
        source: pindel_germline_caller/pindel_sifted
      - id: reference
        source: reference
      - id: pindel_config_template
        source: pindel_config_template
    out:
      - id: indel_vcf
    run: ../../Pindel_GermlineCaller/cwl/pindel_filter.Pindel_GermlineCaller.cwl
    label: Pindel_Filter
  - id: _varscan__germline_caller
    in:
      - id: reference
        source: reference
      - id: bam
        source: bam
    out:
      - id: snp_vcf
      - id: indel_vcf
    run: ../../Varscan_GermlineCaller/cwl/Varscan_GermlineCaller.cwl
    label: Varscan_GermlineCaller
  - id: varscan_vcf_remap_snp
    in:
      - id: input
        source: _varscan__germline_caller/snp_vcf
      - id: germline
        default: true
    out:
      - id: remapped_VCF
    run: ../../varscan_vcf_remap/cwl/varscan_vcf_remap.cwl
    label: varscan_vcf_remap_snp
  - id: varscan_vcf_remap_indel
    in:
      - id: input
        source: _varscan__germline_caller/indel_vcf
      - id: germline
        default: true
    out:
      - id: remapped_VCF
    run: ../../varscan_vcf_remap/cwl/varscan_vcf_remap.cwl
    label: varscan_vcf_remap_indel
  - id: vld_filter_gatk_snp
    in:
      - id: VCF
        source: gatk_germline_caller/snp_vcf
      - id: config
        source: gatk_snp_filter_config
    out:
      - id: output
    run: ../../VLD_FilterVCF/cwl/VLD_FilterVCF.cwl
    label: VLD_Filter_GATK_SNP
  - id: vld_filter_gatk_indel
    in:
      - id: VCF
        source: gatk_germline_caller/indel_vcf
      - id: config
        source: gatk_indel_filter_config
    out:
      - id: output
    run: ../../VLD_FilterVCF/cwl/VLD_FilterVCF.cwl
    label: VLD_Filter_GATK_indel
  - id: vld_filter_pindel
    in:
      - id: VCF
        source: pindel_filter/indel_vcf
      - id: config
        source: pindel_filter_config
    out:
      - id: output
    run: ../../VLD_FilterVCF/cwl/VLD_FilterVCF.cwl
    label: VLD_Filter_Pindel
  - id: vld_filter_varscan_snp
    in:
      - id: VCF
        source: varscan_vcf_remap_snp/remapped_VCF
      - id: config
        source: varscan_snp_filter_config
    out:
      - id: output
    run: ../../VLD_FilterVCF/cwl/VLD_FilterVCF.cwl
    label: VLD_Filter_varscan_snp
  - id: vld_filter_varscan_indel
    in:
      - id: VCF
        source: varscan_vcf_remap_indel/remapped_VCF
      - id: config
        source: varscan_indel_filter_config
    out:
      - id: output
    run: ../../VLD_FilterVCF/cwl/VLD_FilterVCF.cwl
    label: VLD_Filter_varscan_indel
  - id: merge_vcf
    in:
      - id: reference
        source: reference
      - id: gatk_indel
        source: vld_filter_gatk_indel/output
      - id: gatk_snv
        source: vld_filter_gatk_snp/output
      - id: pindel
        source: vld_filter_pindel/output
      - id: varscan_indel
        source: vld_filter_varscan_indel/output
      - id: varscan_snv
        source: vld_filter_varscan_snp/output
    out:
      - id: merged_vcf
    run: ../../MergeFilterVCF/cwl/MergeVCF.cwl
    label: Merge_VCF
  - id: filter_vcf
    in:
      - id: input_vcf
        source: merge_vcf/merged_vcf
    out:
      - id: merged_vcf
    run: ../../MergeFilterVCF/cwl/FilterVCF.cwl
    label: Merge_Filter_VCF
  - id: roi_filter
    in:
      - id: VCF_A
        source: filter_vcf/merged_vcf
      - id: BED
        source: ROI_BED
    out:
      - id: output
    run: ../../HotspotFilter/cwl/hotspotfilter.cwl
    label: ROI_Filter
  - id: vep_annotate
    in:
      - id: input_vcf
        source: roi_filter/output
      - id: reference_fasta
        source: reference
      - id: assembly
        source: assembly
      - id: vep_cache_version
        source: vep_cache_version
      - id: vep_cache_gz
        source: vep_cache_gz
    out:
      - id: output_dat
    run: ../../TinDaisy-VEP/cwl/vep_annotate.cwl
    label: vep_annotate
  - id: canonical_filter
    in:
      - id: VCF_A
        source: vep_annotate/output_dat
      - id: BED
        source: Canonical_BED
      - id: keep_only_pass
        default: true
    out:
      - id: output
    run: ../../HotspotFilter/cwl/hotspotfilter.cwl
    label: CanonicalFilter
  - id: vcf2maf
    in:
      - id: ref-fasta
        source: reference
      - id: assembly
        source: assembly
      - id: input-vcf
        source: canonical_filter/output
      - id: tumor_barcode
        source: tumor_barcode
    out:
      - id: output
    run: ../../vcf2maf-CWL/cwl/vcf2maf.cwl
    label: vcf2maf
requirements: []