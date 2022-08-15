using UnityEngine;

public class MultiCompile : MonoBehaviour
{
    private void OnGUI()
    {
        KeywordToggleGUI("RED");
        KeywordToggleGUI("GREEN");
    }

    private void KeywordToggleGUI(string keyword)
    {
        // IsKeywordEnabledでkeywordを確認しに行く。
        bool enabled = GUILayout.Toggle(Shader.IsKeywordEnabled(keyword), keyword);

        if (enabled)
        {
            // ShaderのEnableKeyword関数で有効にする。
            Shader.EnableKeyword(keyword);
        }
        else
        {
            // DisableKeywordで無効にすることもできる。
            Shader.DisableKeyword(keyword);
        }
    }
}
