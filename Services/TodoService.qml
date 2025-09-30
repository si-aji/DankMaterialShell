import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root

    property string todoFilePath: Paths.strip(Paths.home) + "/TODO.md"
    property var doingTasks: []
    property var finishedTasks: []
    property bool featureAvailable: true

    signal tasksUpdated()

    property string _pendingWriteContent: ""

    FileView {
        id: todoFileView
        path: root.todoFilePath
        preload: true
        watchChanges: true
        atomicWrites: true
        blockWrites: true
        printErrors: true

        function updateTasksFromContent(content) {
            const parsed = parseTodoFile(content || "")
            root.doingTasks = parsed.doing
            root.finishedTasks = parsed.finished
            root.tasksUpdated()
        }

        onLoaded: {
            updateTasksFromContent(todoFileView.text())
        }

        onLoadFailed: (error) => {
            if (!error || (error.indexOf("ENOENT") === -1 && error.indexOf("No such file") === -1)) {
                console.warn("Failed to load TODO file:", error)
            }
            root.doingTasks = []
            root.finishedTasks = []
            root.tasksUpdated()
        }

        onFileChanged: {
            todoFileView.reload()
        }

        onSaveFailed: (error) => {
            console.warn("Failed to write TODO file:", error)
        }
    }

    Process {
        id: writeFileProcess
        running: false

        onExited: (exitCode) => {
            if (exitCode !== 0) {
                console.warn("Failed to write TODO file, exit code:", exitCode)
            } else {
                todoFileView.reload()
            }

            if (root._pendingWriteContent !== "") {
                const next = root._pendingWriteContent
                root._pendingWriteContent = ""
                Qt.callLater(() => startWriteProcess(next))
            }
        }
    }

    function parseTodoFile(content) {
        const lines = content.split('\n')
        const doing = []
        const finished = []

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim()
            if (line.startsWith('[ ] ')) {
                doing.push({
                    text: line.substring(4).trim(),
                    lineNumber: i
                })
            } else if (line.startsWith('[x] ')) {
                finished.push({
                    text: line.substring(4).trim(),
                    lineNumber: i
                })
            }
        }

        return { doing, finished }
    }

    function formatTasksForFile(doingTasks, finishedTasks) {
        let content = ""

        // Add doing tasks
        for (let i = 0; i < doingTasks.length; i++) {
            content += "[ ] " + doingTasks[i].text + "\n"
        }

        // Add empty line separator if we have both types
        if (doingTasks.length > 0 && finishedTasks.length > 0) {
            content += "\n"
        }

        // Add finished tasks
        for (let i = 0; i < finishedTasks.length; i++) {
            content += "[x] " + finishedTasks[i].text + "\n"
        }

        return content
    }

    function loadTasks() {
        todoFileView.reload()
    }

    function startWriteProcess(content) {
        writeFileProcess.command = [
            "python3",
            "-c",
            "import pathlib, sys; pathlib.Path(sys.argv[1]).write_text(sys.argv[2], encoding='utf-8')",
            root.todoFilePath,
            content
        ]
        writeFileProcess.running = true
    }

    function saveTasks() {
        const content = formatTasksForFile(root.doingTasks, root.finishedTasks)

        if (writeFileProcess.running) {
            root._pendingWriteContent = content
        } else {
            startWriteProcess(content)
        }

        console.log("Saving tasks to:", root.todoFilePath)
    }

    function addTask(text) {
        if (text.trim() === "") return false

        const task = {
            text: text.trim(),
            lineNumber: root.doingTasks.length + root.finishedTasks.length,
            timestamp: Date.now()
        }

        // Add to beginning of doingTasks (newest first)
        root.doingTasks.unshift(task)

        saveTasks()
        root.tasksUpdated()
        return true
    }

    function finishTask(index) {
        if (index < 0 || index >= root.doingTasks.length) return false

        const task = root.doingTasks.splice(index, 1)[0]
        task.finishedTimestamp = Date.now()

        // Add to beginning of finishedTasks (most recently finished first)
        root.finishedTasks.unshift(task)

        saveTasks()
        root.tasksUpdated()
        return true
    }

    function unfinishTask(index) {
        if (index < 0 || index >= root.finishedTasks.length) return false

        const task = root.finishedTasks.splice(index, 1)[0]
        delete task.finishedTimestamp

        // Add to beginning of doingTasks (newly restored first)
        root.doingTasks.unshift(task)

        saveTasks()
        root.tasksUpdated()
        return true
    }

    function removeDoingTask(index) {
        if (index < 0 || index >= root.doingTasks.length) return false

        root.doingTasks.splice(index, 1)
        saveTasks()
        root.tasksUpdated()
        return true
    }

    function removeFinishedTask(index) {
        if (index < 0 || index >= root.finishedTasks.length) return false

        root.finishedTasks.splice(index, 1)
        saveTasks()
        root.tasksUpdated()
        return true
    }

    function finishAllTasks() {
        if (root.doingTasks.length === 0) return false

        const tasks = root.doingTasks.splice(0, root.doingTasks.length)
        const now = Date.now()

        // Add finished timestamp and add to beginning (most recently finished first)
        tasks.forEach(task => {
            task.finishedTimestamp = now
            root.finishedTasks.unshift(task)
        })

        saveTasks()
        root.tasksUpdated()
        return true
    }

    function clearAllTasks() {
        if (root.finishedTasks.length === 0) return false

        root.finishedTasks = []
        saveTasks()
        root.tasksUpdated()
        return true
    }

    function editDoingTask(index, newText) {
        if (index < 0 || index >= root.doingTasks.length) return false
        if (newText.trim() === "") return false

        root.doingTasks[index].text = newText.trim()
        saveTasks()
        root.tasksUpdated()
        return true
    }

    function editFinishedTask(index, newText) {
        if (index < 0 || index >= root.finishedTasks.length) return false
        if (newText.trim() === "") return false

        root.finishedTasks[index].text = newText.trim()
        saveTasks()
        root.tasksUpdated()
        return true
    }

    // Initialize on component creation
    Component.onCompleted: {
        console.log("TodoService tracking file:", root.todoFilePath)
        loadTasks()
    }
}
