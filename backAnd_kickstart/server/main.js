var demo = {
    getTooltip : undefined // Loaded later
  };

  i18nProvider.getJson('json', 'tooltipdata',
    function(tooltipdata) {
      demo.getTooltip = i18nTranslatorFactory.createTranslator(tooltipdata);
    }
  );