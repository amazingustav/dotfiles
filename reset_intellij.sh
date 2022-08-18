#!/bin/bash

echo "removing evaluation key"
rm ~/.IntelliJIdea*/config/eval/idea*.evaluation.key

echo "removing jetbrains .java configs"
rm -r ~/.java/.userPrefs/jetbrains

echo "resetting evalsprt in options.xml"
sed -i '/evlsprt/d' ~/.IntelliJIdea*/config/options/options.xml

echo "resetting evalsprt in other.xml"
sed -i '/evlsprt/d' ~/.IntelliJIdea*/config/options/other.xml

echo "resetting evalsprt in prefs.xml"
sed -i '/evlsprt/d' ~/.java/.userPrefs/prefs.xml
