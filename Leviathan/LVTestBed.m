//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#import "lexer.h"
#import "coll.h"
#import "parser.h"
#import "atom.h"

struct LVTokenList {
    LVToken** toks;
    size_t size;
};

#define TOKARRAY(...) ((LVToken*[]){ __VA_ARGS__ })
#define TOKCOUNT(...) (sizeof(TOKARRAY(__VA_ARGS__)) / sizeof(LVToken*))
#define TOKLIST(...) ((struct LVTokenList){TOKARRAY(__VA_ARGS__), TOKCOUNT(__VA_ARGS__)})
#define TOK(typ, chr) LVTokenCreate(typ, bfromcstr(chr))

static void LVLexerShouldEqual(char* raw, struct LVTokenList expected) {
    size_t actual_size;
    LVToken** tokens = LVLex(raw, &actual_size);
    
    if (actual_size != expected.size) {
        printf("wrong size: %s\n", raw);
        printf("want:\n");
        for (size_t i = 0; i < expected.size; i++) {
            LVToken* tok = expected.toks[i];
            printf("[%s]\n", tok->val->data);
        }
        printf("got:\n");
        for (size_t i = 0; i < actual_size; i++) {
            LVToken* tok = tokens[i];
            printf("[%s]\n", tok->val->data);
        }
        abort();
    }
    
    for (size_t i = 0; i < actual_size; i++) {
        LVToken* t1 = tokens[i];
        LVToken* t2 = expected.toks[i];
        
        if (t1->type != t2->type) {
            printf("wrong token type for: %s\n", raw);
            printf("want val %s, got val %s\n", t2->val->data, t1->val->data);
            printf("want %llu, got %llu\n", t2->type, t1->type);
            abort();
        }
        
        if (bstrcmp(t1->val, t2->val) != 0) {
            printf("wrong token string for: %s\n", raw);
            printf("want %s, got %s\n", t2->val->data, t1->val->data);
            abort();
        }
    }
}

@implementation LVTestBed

+ (void) runTests {
    return;
    
    LVLexerShouldEqual("(foobar)", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_LParen, "("), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_RParen, ")"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("foobar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("(    foobar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_LParen, "("), TOK(LVTokenType_Spaces, "    "), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("~", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Unquote, "~"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("~@", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Splice, "~@"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("\"yes\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_String, "\"yes\""), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("\"y\\\"es\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_String, "\"y\\\"es\""), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual(";foobar\nhello", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_CommentLiteral, ";foobar"), TOK(LVTokenType_Newline, "\n"), TOK(LVTokenType_Symbol, "hello"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("foo 123 :hello", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Number, "123"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Keyword, ":hello"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("#'foo", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Var, "#'foo"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#(foo)", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_AnonFnStart, "#("), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_RParen, ")"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#{foo}", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_SetStart, "#{"), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_RBrace, "}"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#_foo", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_ReaderCommentStart, "#_"), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#foo bar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_ReaderMacro, "#foo"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Symbol, "bar"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("#\"yes\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Regex, "#\"yes\""), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#\"y\\\"es\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Regex, "#\"y\\\"es\""), TOK(LVTokenType_FileEnd, "")));
    
    
    
    
    {
        LVColl* top = LVParse("foo");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("(foo)");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_List);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("[foo]");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_Vector);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("#(foo)");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_AnonFn);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("{foo bar}");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_Map);
        assert(list->children.len == 3);
        
        {
            LVAtom* atom = (void*)list->children.elements[0];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Symbol);
            assert(atom->token->type == LVTokenType_Symbol);
            assert(biseq(atom->token->val, bfromcstr("foo")));
        }
        
        {
            LVAtom* atom = (void*)list->children.elements[1];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Spaces);
            assert(atom->token->type == LVTokenType_Spaces);
            assert(biseq(atom->token->val, bfromcstr(" ")));
        }
        
        {
            LVAtom* atom = (void*)list->children.elements[2];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Symbol);
            assert(atom->token->type == LVTokenType_Symbol);
            assert(biseq(atom->token->val, bfromcstr("bar")));
        }
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("123");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Number);
        assert(atom->token->type == LVTokenType_Number);
        assert(biseq(atom->token->val, bfromcstr("123")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse(":bla");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Keyword);
        assert(atom->token->type == LVTokenType_Keyword);
        assert(biseq(atom->token->val, bfromcstr(":bla")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("((baryes)foo((no)))");
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("((bar yes) foo ((no)))");
        LVCollDestroy(top);
    }
    
    {
        char* it = ""
        "(ns datomic\n"
        "  (:require ;;[clojure.data.json :as json]\n"
        "            ;;[clojure.java.io :as io]\n"
        "            ;;[clojure.pprint :as pp]\n"
        "            [datomic.require :as req]\n"
        "            [datomic.cli :as cli]))\n"
        "\n"
        "(def commands\n"
        "  \"Map of command names to descriptions of command arguments.\"\n"
        "   {'create-dynamodb-system\n"
        "    {:f 'datomic.provisioning.aws/create-system-command\n"
        "     :named #{{:long-name :region :required true :doc \"AWS region for DynamoDB table\"}\n"
        "              {:long-name :table-name :required true :doc \"DynamoDB table name\"}\n"
        "              {:long-name :read-capacity :required false :default 10 :coerce #(Long. %) :doc \"read capacity\"}\n"
        "              {:long-name :write-capacity :required false :default 5 :coerce #(Long. %) :doc \"write capacity\"}}\n"
        "     :positional [:region :table-name :read-capacity :write-capacity]}\n"
        "    'create-cf-template\n"
        "    {:f 'datomic.provisioning.aws/create-cf-template\n"
        "     :named #{{:long-name :ddb-properties :required true :doc \"DynamoDB properties file\"}\n"
        "              {:long-name :cf-properties :required true :doc \"CloudFormation properties file\"}\n"
        "              {:long-name :json-template :required true :doc \"CloudFormation template file\"}}\n"
        "     :positional [:ddb-properties :cf-properties :json-template]}\n"
        "    'run-from-env\n"
        "    {:f 'datomic.cli/run-from-env}\n"
        "    'run-from-properties\n"
        "    {:f 'datomic.cli/run-from-properties\n"
        "     :named #{{:long-name :fn :required true :doc \"function name\" :coerce symbol}\n"
        "              {:long-name :properties :required true :doc \"properties file or URI\"}}\n"
        "     :positional [:fn :properties]}\n"
        "    'create-aws-credentials\n"
        "    {:f 'datomic.iam/create-credentials-command\n"
        "     :named #{{:long-name :prefix :required true :doc \"prefix to use for credentials\"}}\n"
        "     :positional [:prefix]}    \n"
        "    'assign-peer-user\n"
        "    {:f 'datomic.iam/assign-peer-user-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of peer user\"}\n"
        "              {:long-name :table-name :required true :doc \"dynamodb table name\"}}\n"
        "     :positional [:user-name :table-name]}\n"
        "    'assign-transactor-dynamo-user\n"
        "    {:f 'datomic.iam/assign-transactor-dynamo-user-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of transactor dynamo user\"}\n"
        "              {:long-name :table-name :required true :doc \"dynamodb table name\"}}\n"
        "     :positional [:user-name :table-name]}\n"
        "    'assign-transactor-log-user\n"
        "    {:f 'datomic.iam/assign-transactor-log-user-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of transactor log user\"}\n"
        "              {:long-name :bucket-name :required true :doc \"name of s3 bucket for logs\"}}\n"
        "     :positional [:user-name :bucket-name]}\n"
        "    'assign-transactor-metrics-user\n"
        "    {:f 'datomic.iam/assign-transactor-metrics-user-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of transactor metrics user\"}}\n"
        "     :positional [:user-name]}\n"
        "    'dynamo-r-policy\n"
        "    {:f 'datomic.iam/dynamo-r-policy-command\n"
        "     :named #{{:long-name :account-id :required true :doc \"AWS account id\"}\n"
        "              {:long-name :table-name :required true :doc \"dynamodb table name\"}}\n"
        "     :positional [:account-id :table-name]}\n"
        "    'dynamo-rw-policy\n"
        "    {:f 'datomic.iam/dynamo-rw-policy-command\n"
        "     :named #{{:long-name :account-id :required true :doc \"AWS account id\"}\n"
        "              {:long-name :table-name :required true :doc \"dynamodb table name\"}}\n"
        "     :positional [:account-id :table-name]}\n"
        "    'metrics-w-policy\n"
        "    {:f 'datomic.iam/metrics-w-policy-command}\n"
        "    's3-w-policy\n"
        "    {:f 'datomic.iam/s3-w-policy-command\n"
        "     :named #{{:long-name :bucket-name :required true :doc \"name of s3 bucket to use for logs\"}}\n"
        "     :positional [:bucket-name]}\n"
        "    'create-cf-stack\n"
        "    {:f 'datomic.cloudformation/create-stack-command\n"
        "     :named #{{:long-name :region :required true :doc \"AWS region\"}\n"
        "              {:long-name :stack-name :required true :doc \"name of new cloud formation stack\"}\n"
        "              {:long-name :template-file :required true :doc \"name of template file for new stack\"}}\n"
        "     :positional [:region :stack-name :template-file]}\n"
        "    'delete-cf-stack\n"
        "    {:f 'datomic.cloudformation/delete-stack-command\n"
        "     :named #{{:long-name :region :required true :doc \"AWS region\"}\n"
        "              {:long-name :stack-name :required true :doc \"name of cloud formation stack to delete\"}}\n"
        "     :positional [:region :stack-name]}\n"
        "    'ec2-authorize-security-group-ingress\n"
        "    {:f 'datomic.ec2/authorize-security-group-ingress-command\n"
        "     :named #{{:long-name :group-name :required true :doc \"name of security group\"}\n"
        "              {:long-name :protocol :required true :doc \"protocol to allow (tcp or udp)\"}\n"
        "              {:long-name :port :required true :coerce #(Integer. %) :doc \"ip port number\"}\n"
        "              {:long-name :address :required true :doc \"ip address\"}}\n"
        "     :positional [:group-name :address :protocol :port]}    \n"
        "    'ec2-create-security-group\n"
        "    {:f 'datomic.ec2/create-security-group-command\n"
        "     :named #{{:long-name :group-name :required true :doc \"name of new security group\"}\n"
        "              {:long-name :description :required true :doc \"description of new security group\"}}\n"
        "     :positional [:group-name :description]}\n"
        "    'iam-create-access-key\n"
        "    {:f 'datomic.iam/create-access-key-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of user to create access key for\"}}\n"
        "     :positional [:user-name]}\n"
        "    'iam-create-user\n"
        "    {:f 'datomic.iam/create-user-command\n"
        "     :named #{{:long-name :user-name :required true :doc \"name of new user\"}}\n"
        "     :positional [:user-name]}\n"
        "    'iam-create-group\n"
        "    {:f 'datomic.iam/create-group-command\n"
        "     :named #{{:long-name :group-name :required true :doc \"name of new group\"}}\n"
        "     :positional [:group-name]}\n"
        "    'iam-get-account-id\n"
        "    {:f 'datomic.iam/get-account-id-command}\n"
        "    'ensure-transactor\n"
        "    {:f 'datomic.provisioning.aws/ensure-transactor\n"
        "     :named #{{:long-name :input-file :required true :doc \"name of transactor.properties to consume\"}\n"
        "              {:long-name :output-file :required true :doc \"name of transactor.properties to produce\"}}\n"
        "     :positional [:input-file :output-file]}\n"
        "    'ensure-cf\n"
        "    {:f 'datomic.provisioning.aws/ensure-cf\n"
        "     :named #{{:long-name :input-file :required true :doc \"name of cloudformation.properties to consume\"}\n"
        "              {:long-name :output-file :required true :doc \"name of cloudformation.properties to produce\"}}\n"
        "     :positional [:input-file :output-file]}\n"
        "    'backup-db\n"
        "    {:f 'datomic.backup-cli/backup\n"
        "     :named #{{:long-name :from-db-uri :required true :doc \"URI for backup source\"}\n"
        "              {:long-name :to-backup-uri :required true :doc \"URI for backup destination\"}}\n"
        "     :positional [:from-db-uri :to-backup-uri]}\n"
        "    'list-backups\n"
        "    {:f 'datomic.backup-cli/list-backups\n"
        "     :named #{{:long-name :backup-uri :required true :doc \"backup URI\"}}\n"
        "     :positional [:backup-uri :to-db-uri]}\n"
        "    'restore-db\n"
        "    {:f 'datomic.backup-cli/restore\n"
        "     :named #{{:long-name :from-backup-uri :required true :doc \"URI for restore source\"}\n"
        "              {:long-name :to-db-uri :required true :doc \"URI for restore destination\"}\n"
        "              {:long-name :t :doc \"Point in time (t) to restore, defaults to most recent\"\n"
        "               :default nil :coerce #(Long. %)}}\n"
        "     :positional [:from-backup-uri :to-db-uri :t]}\n"
        "    })\n"
        "\n"
        "(defn -main\n"
        "  [& args]\n"
        "  (let [command (when-let [cname (first args)]\n"
        "                  (symbol cname))\n"
        "        cli-args (rest args)]\n"
        "    (if-let [{:keys [f named positional vararg]} (get commands command)]\n"
        "      (let [args (cli/parse-or-exit! command cli-args named positional vararg)]\n"
        "        (try\n"
        "          (when-let [result (req/require-and-run f args)]\n"
        "            (println result))\n"
        "          (catch com.amazonaws.AmazonServiceException ase\n"
        "            (println \"*** ERROR\"\n"
        "                     (.getServiceName ase)\n"
        "                     (.getErrorCode ase)\n"
        "                     (.getMessage ase))\n"
        "            (cli/fail (.getMessage ase)))\n"
        "          (catch com.amazonaws.AmazonClientException ace\n"
        "            (println \"*** ERROR\" (.getMessage ace))\n"
        "            (cli/fail (.getMessage ace)))\n"
        "          (catch Throwable t\n"
        "            (.printStackTrace t)\n"
        "            (cli/fail (.getMessage t))))\n"
        "        (when @cli/exit-after-command\n"
        "          (System/exit (if @cli/failed -1 0))))\n"
        "      (do\n"
        "        (println (str \"Command \" command \" not found. Available commands: \"))\n"
        "        (doseq [[k v] (sort commands)]\n"
        "          (println \"\t\" k))\n"
        "        (System/exit -1)))))\n"
        ;
        
        LVColl* top = LVParse(it);
        LVCollDestroy(top);
    }
    
    printf("ok\n");
//    [NSApp terminate:self];
}

@end
