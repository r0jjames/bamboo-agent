package lab.agent;

import com.atlassian.bamboo.specs.api.BambooSpec;
import com.atlassian.bamboo.specs.api.builders.BambooKey;
import com.atlassian.bamboo.specs.api.builders.plan.Job;
import com.atlassian.bamboo.specs.api.builders.plan.Plan;
import com.atlassian.bamboo.specs.api.builders.plan.Stage;
import com.atlassian.bamboo.specs.api.builders.plan.configuration.ConcurrentBuilds;
import com.atlassian.bamboo.specs.api.builders.project.Project;
import com.atlassian.bamboo.specs.api.builders.requirement.Requirement;
import com.atlassian.bamboo.specs.builders.task.CheckoutItem;
import com.atlassian.bamboo.specs.builders.task.ScriptTask;
import com.atlassian.bamboo.specs.builders.task.VcsCheckoutTask;

@BambooSpec
public class BuildAgentImageSpec {

    Plan plan() {
        return new Plan(
                new Project().key(new BambooKey("AGENT")).name("bamboo-agent"),
                "Build Agent Image", new BambooKey("BUILD"))
            .description("Build + push the containerized Bamboo CI agent via kaniko")
            .pluginConfigurations(new ConcurrentBuilds().useSystemWideDefault(false))
            .stages(
                new Stage("Validate").jobs(
                    new Job("Validate", new BambooKey("VAL"))
                        .requirements(new Requirement("agent.role").matchValue("ci").matchType(Requirement.MatchType.EQUALS))
                        .tasks(
                            new VcsCheckoutTask().description("checkout")
                                .checkoutItems(new CheckoutItem().defaultRepository()),
                            new ScriptTask().description("validate specs")
                                .inlineBody("cd bamboo-agent-deployment/specs && mvn -q test"))),
                new Stage("Build+Push").jobs(
                    new Job("BuildPush", new BambooKey("BP"))
                        .requirements(new Requirement("agent.role").matchValue("ci").matchType(Requirement.MatchType.EQUALS))
                        .tasks(
                            new VcsCheckoutTask().description("checkout")
                                .checkoutItems(new CheckoutItem().defaultRepository()),
                            new ScriptTask().description("kaniko build + push")
                                .inlineBody("bamboo-agent-deployment/scripts/build-image.sh"))));
    }

    public static void main(String[] args) {
        // Published via `mvn compile exec:java` against a running server; the
        // BambooServer URL is supplied at publish time (see repo README).
        throw new UnsupportedOperationException(
            "Publish with the forge-lab specs-publish pattern; plan() is unit-validated offline.");
    }
}
