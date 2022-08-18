#!/bin/bash
rm ~/.IntelliJIdea*/config/eval/idea*.evaluation.key
rm -r ~/.java/.userPrefs/jetbrains
sed -i '/evlsprt/d' ~/.DataGrip*/config/options/other.xml
sed -i '/evlsprt/d' ~/.java/.userPrefs/prefs.xml
