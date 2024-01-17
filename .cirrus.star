load("github.com/SonarSource/cirrus-modules@v2", "load_features")


def main(ctx):
    return load_features(ctx, only_if=dict(),
                         aws=dict(env_type="dev", cluster_name="CirrusCI-5-pr-115",
                                  subnet_ids=["subnet-0fb8eb63a20348b2b", "subnet-02a7324c4077de09b",
                                              "subnet-041e1c25685502b8c"]))
