# -*- coding:utf-8 -*-
import jpype
from jpype import *
import os.path

class Xmlanalysis():

	jarpath = os.path.join(os.path.abspath('.'),"target/smartcheck-2.1-SNAPSHOT-jar-with-dependencies.jar")
	JDClass = None

	def __init__(self):
		startJVM(getDefaultJVMPath(),"-ea","-Djava.class.path=%s" % self.jarpath)
		self.JDClass = JClass("ru.smartdec.smartcheck.app.cli.Tool")

	def _analysispath(self, path):
		output = self.JDClass.smartcheckaudit(path)
		return output

	def _shutdownjvm(self):
		jpype.shutdownJVM()