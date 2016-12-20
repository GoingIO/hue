// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

DataManipulation
 : LoadStatement
 | ImportStatement
 | ExportStatement
 ;

DataManipulation_EDIT
 : LoadStatement_EDIT
 | ImportStatement_EDIT
 | ExportStatement_EDIT
 ;

LoadStatement
 : AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' AnyTable SchemaQualifiedTableIdentifier OptionalPartitionSpec
   {
     addTablePrimary($9);
   }
 ;

LoadStatement_EDIT
 : AnyLoad 'CURSOR'
   {
     if (isHive()) {
       suggestKeywords(['DATA LOCAL INPATH', 'DATA INPATH']);
     } else if (isImpala()) {
       suggestKeywords(['DATA INPATH']);
     }
   }
 | AnyLoad AnyData OptionalHiveLocal 'CURSOR'
   {
     if (isHive() && !$3) {
       suggestKeywords(['INPATH', 'LOCAL INPATH']);
     } else {
       suggestKeywords(['INPATH']);
     }
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath_EDIT OptionalOverwrite
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'CURSOR'
   {
     if (!$6) {
       suggestKeywords(['OVERWRITE INTO TABLE', 'INTO TABLE']);
     } else {
       suggestKeywords(['INTO TABLE']);
     }
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' 'CURSOR'
   {
     suggestKeywords([ 'TABLE' ]);
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' AnyTable 'CURSOR'
   {
     suggestTables();
     suggestDatabases({ appendDot: true });
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' AnyTable SchemaQualifiedTableIdentifier_EDIT OptionalPartitionSpec
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' AnyTable SchemaQualifiedTableIdentifier OptionalPartitionSpec 'CURSOR'
   {
     addTablePrimary($9);
     if (!$10) {
       suggestKeywords(['PARTITION']);
     }
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath OptionalOverwrite 'INTO' AnyTable SchemaQualifiedTableIdentifier OptionalPartitionSpec_EDIT
   {
     addTablePrimary($9);
   }
 | AnyLoad AnyData OptionalHiveLocal AnyInpath HdfsPath_EDIT OptionalOverwrite 'INTO' AnyTable SchemaQualifiedTableIdentifier OptionalPartitionSpec
   {
     addTablePrimary($9);
   }
 ;

OptionalOverwrite
 :
 | '<hive>OVERWRITE'
 | '<impala>OVERWRITE'
 ;

OptionalHiveLocal
 :
 | '<hive>LOCAL'
 ;

AnyLoad
 : '<hive>LOAD'
 | '<impala>LOAD'
 ;

AnyData
 : '<hive>DATA'
 | '<impala>DATA'
 ;

AnyInpath
 : '<hive>INPATH'
 | '<impala>INPATH'
 ;

ImportStatement
 : '<hive>IMPORT' OptionalTableWithPartition PushHdfsLexerState 'FROM' HdfsPath OptionalHdfsLocation
 ;

ImportStatement_EDIT
 : '<hive>IMPORT' 'CURSOR' OptionalTableWithPartition
   {
     if (!$3) {
       suggestKeywords(['EXTERNAL TABLE', 'FROM', 'TABLE']);
     } else if (!$3.hasExternal) {
       suggestKeywords(['EXTERNAL']);
     }
   }
 | '<hive>IMPORT' TableWithPartition 'CURSOR'
   {
     if ($2.suggestKeywords) {
        suggestKeywords(createWeightedKeywords($2.suggestKeywords, 2).concat(['FROM']));
      } else {
        suggestKeywords(['FROM']);
      }
   }
 | '<hive>IMPORT' TableWithPartition_EDIT
 | '<hive>IMPORT' OptionalTableWithPartition PushHdfsLexerState 'FROM' HdfsPath_EDIT OptionalHdfsLocation
 | '<hive>IMPORT' OptionalTableWithPartition PushHdfsLexerState 'FROM' HdfsPath HdfsLocation_EDIT
 | '<hive>IMPORT' OptionalTableWithPartition PushHdfsLexerState 'FROM' HdfsPath OptionalHdfsLocation 'CURSOR'
   {
     if (!$6) {
       suggestKeywords(['LOCATION']);
     }
   }
 | '<hive>IMPORT' 'CURSOR' OptionalTableWithPartition PushHdfsLexerState 'FROM' HdfsPath OptionalHdfsLocation
   {
     if (!$3) {
       suggestKeywords(['EXTERNAL TABLE', 'TABLE']);
     } else if (!$3.hasExternal) {
       suggestKeywords(['EXTERNAL']);
     }
   }
| '<hive>IMPORT' TableWithPartition_EDIT PushHdfsLexerState 'FROM' HdfsPath OptionalHdfsLocation
 | '<hive>IMPORT' TableWithPartition 'CURSOR' PushHdfsLexerState 'FROM' HdfsPath OptionalHdfsLocation
    {
      if ($2.suggestKeywords) {
        suggestKeywords(createWeightedKeywords($2.suggestKeywords, 2).concat(['FROM']));
      }
    }
 ;

OptionalTableWithPartition
 :
 | TableWithPartition
 ;

TableWithPartition
 : '<hive>EXTERNAL' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec
   {
     addTablePrimary($3);
     if (!$4) {
       $$ = { hasExternal: true, suggestKeywords: ['PARTITION'] };
     } else {
       $$ = { hasExternal: true }
     }
   }
 | '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec
   {
     addTablePrimary($2);
     if (!$3) {
       $$ = { suggestKeywords: ['PARTITION'] };
     }
   }
 ;

TableWithPartition_EDIT
 : '<hive>EXTERNAL' 'CURSOR'
   {
     suggestKeywords(['TABLE']);
   }
 | '<hive>EXTERNAL' '<hive>TABLE' 'CURSOR'
   {
     suggestTables();
     suggestDatabases({ appendDot: true });
   }
 | '<hive>EXTERNAL' '<hive>TABLE' SchemaQualifiedTableIdentifier_EDIT OptionalPartitionSpec
 | '<hive>EXTERNAL' '<hive>TABLE' SchemaQualifiedTableIdentifier PartitionSpec_EDIT
   {
     addTablePrimary($3);
   }
 | '<hive>TABLE' 'CURSOR'
   {
     suggestTables();
     suggestDatabases({ appendDot: true });
   }

 | '<hive>TABLE' SchemaQualifiedTableIdentifier_EDIT OptionalPartitionSpec
 | '<hive>TABLE' SchemaQualifiedTableIdentifier PartitionSpec_EDIT
   {
     addTablePrimary($3);
   }
 ;

ExportStatement
 : '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath
   {
     addTablePrimary($3);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath '<hive>FOR' '<hive>REPLICATION' '(' QuotedValue ')'
   {
     addTablePrimary($3);
   }
 ;

ExportStatement_EDIT
 : '<hive>EXPORT' 'CURSOR'
   {
     suggestKeywords(['TABLE']);
   }
 | '<hive>EXPORT' '<hive>TABLE' 'CURSOR'
   {
     suggestTables();
     suggestDatabases({ appendDot: true });
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier_EDIT
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec 'CURSOR'
   {
     addTablePrimary($3);
     if (!$4) {
       suggestKeywords([{ weight: 2, value: 'PARTITION' }, { weight: 1, value: 'TO' }]);
     } else {
       suggestKeywords([ 'TO' ]);
     }
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier PartitionSpec_EDIT
   {
     addTablePrimary($3);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath_EDIT
   {
     addTablePrimary($3);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath 'CURSOR'
   {
     addTablePrimary($3);
     suggestKeywords(['FOR replication()']);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath '<hive>FOR' 'CURSOR'
   {
     addTablePrimary($3);
     suggestKeywords(['replication()']);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier_EDIT OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier_EDIT OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath '<hive>FOR' '<hive>REPLICATION' '(' QuotedValue ')'
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec 'CURSOR' PushHdfsLexerState 'TO' HdfsPath
   {
     addTablePrimary($3);
     if (!$4) {
       suggestKeywords(['PARTITION']);
     }
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec 'CURSOR' PushHdfsLexerState 'TO' HdfsPath '<hive>FOR' '<hive>REPLICATION' '(' QuotedValue ')'
   {
     addTablePrimary($3);
     if (!$4) {
       suggestKeywords(['PARTITION']);
     }
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier PartitionSpec_EDIT PushHdfsLexerState 'TO' HdfsPath
   {
     addTablePrimary($3);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier PartitionSpec_EDIT PushHdfsLexerState 'TO' HdfsPath '<hive>FOR' '<hive>REPLICATION' '(' QuotedValue ')'
   {
     addTablePrimary($3);
   }
 | '<hive>EXPORT' '<hive>TABLE' SchemaQualifiedTableIdentifier OptionalPartitionSpec PushHdfsLexerState 'TO' HdfsPath_EDIT '<hive>FOR' '<hive>REPLICATION' '(' QuotedValue ')'
   {
     addTablePrimary($3);
   }
 ;